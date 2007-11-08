From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: No implementation of NETLINK_USERSOCK ?
Date: Thu, 8 Nov 2007 22:45:00 +0200
Message-ID: <20071108204500.GB6372@mea-ext.zmailer.org>
References: <20071108151512.GY6372@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:51567 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760237AbXKHUpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 15:45:02 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540074AbXKHUpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 22:45:00 +0200
Content-Disposition: inline
In-Reply-To: <20071108151512.GY6372@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Following up on myself...

On Thu, Nov 08, 2007 at 05:15:12PM +0200, Matti Aarnio wrote:
> Some 6 months ago I asked about a way to make network protocol
> servers(s) that live in userspace, but whose application interface
> still uses kernel socket calls.
> 
> I recall getting an answer that there is  NETLINK_USERSOCK for that
> use.  I have tried to have a look into what NETLINK_USERSOCK
> supplies to its users, but alas there appears to be no implementation
> at all in existence.   Is it some sort of placeholder of things
> to implement some day ?

The more I am reading around places, the more it looks like there
really is no implementation, but somebody thought that such would
be a nice thing to have.

It did appear around  Linux 2.2, and probable reservation maker was
Alexey N. Kuznetsov. 

So, in order to implement the thing, something must be defined at
first.  Requirements are at least:

   - Applications see SOCKET API, and addresses are presentable
     via  struct sockaddr*   -- meaning that 16 bit sa_family leads
     the record, or possibly leading byte is record size and
     second one is family.

   - sa_family number space must be somehow managed, for example
     with file:  /etc/socketfamilies

           #PF_## value: 128-254
           #    nn  'struct sockaddr' size in bytes
           #         # PF_### keyword name
           #                         Explanatory name
           #
           128  36  PF_USERSOCK1     Experimental usersock 1
           129  80  PF_USERSOCK2     Experimental usersock 2
           130  22  PF_USERSOCK3     Experimental usersock 3

     And why not all the built in "hard-coded" ones, too.
 
     The sa_family numbers _must_ be static for at least machine
     runtime, even if they are otherwise quite dynamic in nature.
     (Registering and reading them from /proc/sys/...  -file is
      a possibility.)

   - There is only one  NETLINK_USERSOCK, but it should somehow
     manage N different protocols.  N being at least 32.

   - Netlink itself is unrealiable protocol, but applications
     should still be able to read() and write() from it reliably.
     There is some reliability-thing in documentation.

   - For all intents and purposes the only difference from well
     established socket API based protocols, applications using
     NETLINK_USERSOCK implemented ones shall not be aware of
     anything being different except with the the how PF_NNNN
     literal is resolved.


What else is needed ?
Any pointers on how to construct this framework ?
Or does it exist although I didn't spot it yet ?

/Matti Aarnio
