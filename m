From: "gnehzuil.liu" <gnehzuil.liu@gmail.com>
Subject: Re: TCP fast open question
Date: Sat, 8 Mar 2014 22:47:37 +0800
Message-ID: <1F78DB0B-422E-4095-8A67-5E51526F0E42@gmail.com>
References: <20140308115823.GA3185@gmail.com> <CAEH94LheM=0q_Zp3QTrZ1+GnCH==CYcBZar_tHMc_mhrRw7C9A@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Xiaochen Wang <xiaochen.wxc@alibaba-inc.com>,
	Zheng Liu <wenqing.lz@taobao.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:40602 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbaCHOrq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 09:47:46 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so5402073pab.20
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 06:47:45 -0800 (PST)
In-Reply-To: <CAEH94LheM=0q_Zp3QTrZ1+GnCH==CYcBZar_tHMc_mhrRw7C9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> =D4=DA 2014=C4=EA3=D4=C28=C8=D5=A3=AC=CF=C2=CE=E78:56=A3=ACZhi Yong W=
u <zwu.kernel@gmail.com> =D0=B4=B5=C0=A3=BA
>=20
>> On Sat, Mar 8, 2014 at 7:58 PM, Zheng Liu <gnehzuil.liu@gmail.com> w=
rote:
>> Hi all,
>>=20
>> Now we are trying to use TCP fast open in our nginx server, and we
>> encounter a problem under non-blocking socket.  I appreciate if some=
 one
>> can reply this question.  Thanks in advance.
>>=20
>> I describe our question here.  we have two machines, one is as serve=
r and
>> another is as client.  'net.ipv4.tcp_fastopen' on both of them are s=
et to
>> 3.  The server program looks like below:
>>=20
>>  ...
>>  listenfd =3D socket(AF_INET, SOCK_STREAM, 0);
>>  bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
>>  int tfo_opt =3D 1;
>>  setsockopt(listenfd, SOL_TCP, TCP_LISTEN_INFO, &tfo_opt, sizeof(tfo=
_opt));
> s/TCP_LISTEN_INFO/TCP_FASTOPEN/??

Sigh!  Yes, it's a typo.  Thanks for pointing it out.

Regards,
                                                - Zheng

>>  listen(listenfd, 5);
>>  connfd =3D accept(listenfd, (struct sockaddr *)NULL, NULL);
>>  recv(connfd, &buf, 4096)
>>  ...
>>=20
>> The client program:
>>=20
>>  ...
>>  sockfd =3D socket(AF_INET, SOCK_STREAM, 0);
>>  fcntl(sockfd, F_SETFL, fcntl(sockfd, F_GETFL, 0)|O_NONBLOCK);
>>  sendto(sockfd, msg, strlen(msg), MSG_FASTOPEN,
>>        (struct sockaddr *)&servaddr, sizeof(servaddr);
>>  recv(sockfd, buf, 4096, 0);
>>  ...
>>=20
>> We use a non-blocking socket to connect the server and send some
>> messages.  After calling sendto(2) we always get an EINPROGRESS erro=
r.
>> We think it is reasonable because connect(2) could also return this
>> error with a non-blocking socket and the connection will be establis=
hed
>> later.  The question is *whether or not the data will be sent* after=
 the
>> connection is established.  If I understand correctly, sendto(2) wil=
l
>> return the number of bytes of data queued up in the kernel or sent i=
n
>> the SYN packet.  Even though the EINPROGRESS is returned.  If sendto=
(2)
>> returns -1, that means that no data is queued up in kernel or sent i=
n
>> the packet.  Please correct me if I miss-understand something.
>>=20
>> We run the program in our testing environment, and we use tcpdump(1)=
 to
>> capture the packets.  From the result we can see there is no any dat=
a
>> that is sent.  Then we do another testing that after calling sendto(=
2)
>> the client program will sleep for 5 seconds and then call send(2) to
>> transfer some data.
>>=20
>>  $ ./client xx.xx.xx.xx
>>  ret -1 errno 115
>>=20
>> The program works well.  So that means that after getting a EINPROGR=
ESS
>> error, the program must call send(2) manually.  Is it correct?  If w=
e
>> want to avoid this problem, we need to set 'net.ipv4.tcp_fastopen' t=
o
>> 0x707 ?
>>=20
>> Regards,
>>                                                - Zheng
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
>=20
> --=20
> Regards,
>=20
> Zhi Yong Wu
