From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: Piggyback the final ACK of the three way TCP connection
 establishment with the data
Date: Fri, 23 Mar 2012 08:38:08 -0700
Message-ID: <CAK3+h2yFeww84QStvugyaYGfWsL2cw3TnG3CoeLk-q2pQ70_+w@mail.gmail.com>
References: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
	<1332374452.9433.15.camel@edumazet-glaptop>
	<CAK3+h2ydKQ15U1_2dqWsHAL_LKYm-1xbJvUbeaMJShoOCU_TsA@mail.gmail.com>
	<1332458037.6521.12.camel@edumazet-glaptop>
	<1332458223.6521.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:59205 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab2CWPiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 11:38:09 -0400
Received: by wibhq7 with SMTP id hq7so2169246wib.1
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 08:38:08 -0700 (PDT)
In-Reply-To: <1332458223.6521.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 4:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-03-22 at 16:13 -0700, Eric Dumazet wrote:
>
>> A third possibility (reading the code) if you use non blocking IO, is to
>> send() a message right after connect()
>>
>>
>
> Or use the auto connect on sendto() more probably...
>
> That combines the connect() and send()
>

thanks,

I got the TCP_QUICKACK working, but not the non blocking IO,
basically, what I did is

  if((sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
    perror("Can't create TCP socket");
    return 0;
  }

  val = Fcntl(sock, F_GETFL, 0);
  Fcntl(sock, F_SETFL, val | O_NONBLOCK);


  ip = get_ip(host);
  fprintf(stderr, "IP is %s\n", ip);
  remote = (struct sockaddr_in *)malloc(sizeof(struct sockaddr_in *));
  remote->sin_family = AF_INET;
  tmpres = inet_pton(AF_INET, ip, (void *)(&(remote->sin_addr.s_addr)));
  if( tmpres < 0)
  {
    perror("Can't set remote->sin_addr.s_addr");
    return 0;
  }else if(tmpres == 0)
  {
    fprintf(stderr, "%s is not a valid IP address\n", ip);
    return 0;
  }
  remote->sin_port = htons(PORT);

char *query = "GET / HTTP/1.0\r\nHost: 127.0.0.1\r\n\r\n";

tmpres = sendto(sock, query, strlen(query), 0, (struct sockaddr
*)remote, sizeof(struct sockaddr));

 maybe I mis-interpret you.

Vincent
