From: Brent Cook <bcook@bpointsys.com>
Subject: Re: strange behaviour in ping when specifying timeout in msec
Date: Mon, 10 Aug 2009 14:09:43 -0500
Message-ID: <200908101409.44106.bcook@bpointsys.com>
References: <13b17b8a0908051627n32ce7461j75e8459a2c54909c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Michele BOLOGNA <michele.bologna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 65-36-7-9.static.grandenetworks.net ([65.36.7.9]:21056 "EHLO
	bpointsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751901AbZHJTYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 15:24:53 -0400
In-Reply-To: <13b17b8a0908051627n32ce7461j75e8459a2c54909c@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 August 2009 06:27:14 pm Michele BOLOGNA wrote:
> Dear Mr. Yoshifuji,
> I recently noticed a strange behaviour in ping from iputils.
>
> First of all some information:
> mbologna@neptune:~$ ping -V
> ping utility, iputils-sss20071127
>
> Now, I want to specify a timeout and after it expires I would like
> that ping exits, regardless of the packets received, so I use the -W
> option:
>
>       -W timeout
>               Time to wait for a response, in seconds. The option affects
> only timeout in absense of any responses, otherwise  ping  waits  for two
> RTTs.

If you check out the source to ping, you will see that the results of non-
integer arguments to -W is undefined, since atoi cannot detect errors. In your 
case, its probably being interpreted as 0. You can enter almost any value for 
-W without it showing an error, e.g. 'cat' or 'dog'.

    case 'W':
        lingertime = atoi(optarg);
        if (lingertime < 0 || lingertime > INT_MAX/1000000) {
            fprintf(stderr, "ping: bad linger time.\n");
            exit(2);
        }
        lingertime *= 1000;
        break;

Your best bet is perhaps to modify ping to parse time using strtof perhaps.

 - Brent
