From: "Dimitrios Michailidis" <dm@chelsio.com>
Subject: RE: [PATCH net-next 0/7] cxgb4: new driver submission
Date: Wed, 17 Feb 2010 18:56:33 -0800
Message-ID: <8A71B368A89016469F72CD08050AD33401359B62@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16078 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821Ab0BRCxx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 21:53:53 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 17, 2010 5:59 PM
> To: Dimitrios Michailidis
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next 0/7] cxgb4: new driver submission
> 
> From: Dimitris Michailidis <dm@chelsio.com>
> Date: Wed, 17 Feb 2010 17:37:35 -0800
> 
> >
> > The following 7 patches add a new driver cxgb4 for Chelsio's new 1G
and
> 10G
> > cards.  At this time this is for review and comments, I'll be
sending an
> > updated patch series once any review comments are incorporated.
> 
> There is lots of trailing whitespace added by your changes.
> There's also a case of spaces followed by tab characters in
> the initial indentation of lines.
> 
> What makes those two things so incredibly inexcusable is that the very
> tools we use to add changes to the tree _tell_ you about these things.
> 
> bundle-895.mbox:6829: trailing whitespace.
> 	FW_STAT_TX_PORT_FRAMES_IX,
> bundle-895.mbox:6879: trailing whitespace.
> 	FW_STAT_RX_PORT_PPP7_IX,
> bundle-895.mbox:6985: trailing whitespace.
> 	FW_STAT_LB_PORT_FRAMES_IX,
> bundle-895.mbox:6986: trailing whitespace.
> 	FW_STAT_LB_PORT_BCAST_IX,
> bundle-895.mbox:9918: trailing whitespace.
> 	int ret;
> bundle-895.mbox:10135: space before tab in indent.
>        	if (mac) {
> bundle-895.mbox:12533: trailing whitespace.
>  *	prevent further unmapping attempts.
> bundle-895.mbox:18605: trailing whitespace.
> 
> bundle-895.mbox:18981: trailing whitespace.
> 		dev_info(adap->pdev_dev,
> bundle-895.mbox:19266: trailing whitespace.
> 
> fatal: 10 lines add whitespace errors.
> 
> Such automated clerical issues should be taken care of before you even
> submit this for "review".  It's the same as making sure the code
> compiles.

I apologize for the whitespace damage, I'll fix that asap.


> Also you should use the netdev_*() message logging helpers added
> by Joe Perches instead of your local CMSG_*() hacks.


I saw those patches going in but didn't use them because the messages in
the driver are almost always about the adapter as a whole and not about
any one of its ports (it has several).  The CH_* macros in the driver
expand to the dev_* family of logging helpers.  I could replace them
with the netdev_* family but the netdev used for them will tend to be
arbitrary and I didn't think this was very appropriate.  Let me know.


> Finally, this V_*, S_*, F_* naming scheme for register values is
> backwards and if anything very non-standard.  Please use normal macro
> names for these things so you code is more readable by people who
> have to look at all of the other device drivers in the tree not
> just your's.

The first letter in these macros indicates what the macro is about (S
for shift, M for mask, F for flag, etc) and is the same scheme used in
previous Chelsio drivers.  I can replace them if you want but I wanted
to mention that there's a reasoning for their naming.  Would it help to
add a comment at the top explaining what the first letter designates?

Thanks for the comments.
