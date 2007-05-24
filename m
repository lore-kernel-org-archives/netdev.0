From: jamal <hadi@cyberus.ca>
Subject: Re: Generic netlink interface help
Date: Thu, 24 May 2007 09:51:45 -0400
Message-ID: <1180014705.4092.18.camel@localhost>
References: <20070524095654.GA21180@enneenne.com>
	 <31YAj80s.1180001048.5677350.samuel@sortiz.org>
	 <20070524112144.GB21180@enneenne.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: Rodolfo Giometti <giometti@enneenne.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:29483 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750700AbXEXNvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 09:51:48 -0400
Received: by wr-out-0506.google.com with SMTP id 76so127454wra
        for <netdev@vger.kernel.org>; Thu, 24 May 2007 06:51:47 -0700 (PDT)
In-Reply-To: <20070524112144.GB21180@enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-24-05 at 13:21 +0200, Rodolfo Giometti wrote:
> On Thu, May 24, 2007 at 10:04:08AM -0000, Samuel Ortiz wrote:
> > 
> > Yes it's possible, even though it could be more tedious and painful.
> 
> I know that. Have you some links to suggest to me in order to have
> some programming examples?
> 

For debugging or writting some simple apps you could also use
iproute2/genl
example on my laptop to discover loaded users:

---------------
hadi@lilsol:~$ genl ctrl ls

Name: nlctrl
        ID: 0x10  Version: 0x2  header size: 0  max attribs: 6
        commands supported:
                #1:  ID-0x3  flags-0xe


Name: nl80211
        ID: 0x11  Version: 0x1  header size: 0  max attribs: 22
        commands supported:
                #1:  ID-0x1  flags-0xa
                #2:  ID-0x6  flags-0xa
                #3:  ID-0x8  flags-0xa
                #4:  ID-0x3  flags-0xb
                #5:  ID-0x4  flags-0xb
                #6:  ID-0x5  flags-0xb
                #7:  ID-0xa  flags-0xb
                #8:  ID-0xb  flags-0xa
                #9:  ID-0xf  flags-0xb
                #10:  ID-0x10  flags-0xa
                #11:  ID-0x12  flags-0xb
                #12:  ID-0x13  flags-0xa
                #13:  ID-0x15  flags-0xa
                #14:  ID-0x19  flags-0xb
                #15:  ID-0x17  flags-0xb
                #16:  ID-0x18  flags-0xb
                #17:  ID-0x1a  flags-0xb
                #18:  ID-0x1b  flags-0xa
                #19:  ID-0xd  flags-0xb


Name: TASKSTATS
        ID: 0x12  Version: 0x1  header size: 0  max attribs: 4
        commands supported:
                #1:  ID-0x1  flags-0xa
---------------------------

Load tipc and repeat...

-----------

hadi@lilsol:~$ sudo modprobe tipc
Name: nlctrl
        ID: 0x10  Version: 0x2  header size: 0  max attribs: 6
        commands supported:
                #1:  ID-0x3  flags-0xe


Name: nl80211
        ID: 0x11  Version: 0x1  header size: 0  max attribs: 22
        commands supported:
                #1:  ID-0x1  flags-0xa
                #2:  ID-0x6  flags-0xa
                #3:  ID-0x8  flags-0xa
                #4:  ID-0x3  flags-0xb
                #5:  ID-0x4  flags-0xb
                #6:  ID-0x5  flags-0xb
                #7:  ID-0xa  flags-0xb
                #8:  ID-0xb  flags-0xa
                #9:  ID-0xf  flags-0xb
                #10:  ID-0x10  flags-0xa
                #11:  ID-0x12  flags-0xb
                #12:  ID-0x13  flags-0xa
                #13:  ID-0x15  flags-0xa
                #14:  ID-0x19  flags-0xb
                #15:  ID-0x17  flags-0xb
                #16:  ID-0x18  flags-0xb
                #17:  ID-0x1a  flags-0xb
                #18:  ID-0x1b  flags-0xa
                #19:  ID-0xd  flags-0xb


Name: TASKSTATS
        ID: 0x12  Version: 0x1  header size: 0  max attribs: 4
        commands supported:
                #1:  ID-0x1  flags-0xa


Name: TIPC
        ID: 0x13  Version: 0x1  header size: 8  max attribs: 0
        commands supported:
                #1:  ID-0x1  flags-0x2

===============

You essentially write a little .so in user space that knows how to
access/intepret your kernel module
I know you are avoiding to use external libraries etc; but this may be a
good way to get started.
I can dig up some simple kernel/user code i have and if you bug Thomas
long enough he may give you another sample code he has.

cheers,
jamal

