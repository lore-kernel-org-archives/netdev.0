From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [PATCH iproute2] ip: replace exit with return
Date: Thu, 13 Aug 2015 09:47:07 +0800
Message-ID: <000001d0d569$f7d9e8c0$e78dba40$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
To: "'David Laight'" <David.Laight@ACULAB.COM>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9808 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbHMBrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 21:47:17 -0400
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> From: netdev-owner@vger.kernel.org
> > Sent: 11 August 2015 10:40
> > In our manual, we have this description of 'EXIT STATUS':
> > Exit status is 0 if command was successful, and 1 if there is a syntax
> > error.
> >
> > But we exit in command functions with code -1 when there is a syntax
error.
> > It's better to use return.
> 
> Eh?
> Using exit() makes it much more obvious that the program is going to exit.
> 
> I've not looked at the call site (I'm not entirely sure where this code is
in the
> source tree), but main() shouldn't return -1 any more than exit(-1) is
invalid.
> The domain for both is 0..127.
> So the code should be using a valid value.

1. Using exit(-1) will make program exit with -1. 
    With return -1, the do_cmd() function will make sure 1 is returned.  
	do_cmd()
	{
		xxxx
		return -(c->func(argc-1, argv+1));
		xxxx
	}
2.  Replace with return will confirm with manual description like I said in
last mail.

BRs,
Zhang
> 
> ...
> > diff --git a/ip/ipaddress.c b/ip/ipaddress.c index b7b4e3e..6d29a69
> > 100644
> > --- a/ip/ipaddress.c
> > +++ b/ip/ipaddress.c
> > @@ -1879,5 +1879,5 @@ int do_ipaddr(int argc, char **argv)
> >  	if (matches(*argv, "help") == 0)
> >  		usage();
> >  	fprintf(stderr, "Command \"%s\" is unknown, try \"ip addr
help\".\n",
> *argv);
> > -	exit(-1);
> > +	return -1;
> >  }
> ...
> 
> 	David
