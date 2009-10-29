From: "Neulinger, Nathan" <nneul@mst.edu>
Subject: RE: How to use gretap with bridge?
Date: Thu, 29 Oct 2009 14:01:31 -0500
Message-ID: <846C5B546E47494CBBD796CA8CA1617EA3B428@MST-VMAIL1.srv.mst.edu>
References: <846C5B546E47494CBBD796CA8CA1617EA3B414@MST-VMAIL1.srv.mst.edu> <20091029170631.GA29405@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxtip01-rolla-out.um.umsystem.edu ([209.106.229.47]:56702 "EHLO
	mxtip01-rolla-out.um.umsystem.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755805AbZJ2TB1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 15:01:27 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Further testing - if the leading octet of the 'local' address is even,
it allows it to be added to bridge, if it's odd, it won't.

Any ideas?

-- Nathan

------------------------------------------------------------
Nathan Neulinger                       nneul@mst.edu
Missouri S&T Information Technology    (573) 612-1412
System Administrator - Principal       KD0DMH


> -----Original Message-----
> From: Neulinger, Nathan
> Sent: Thursday, October 29, 2009 1:39 PM
> To: 'netdev@vger.kernel.org'
> Subject: RE: How to use gretap with bridge?
> 
> I've been able to reproduce this with a upstream kernel (2.6.32-rc5) -
> symptom appears to be specific to the IP addresses specified on the ip
> command, but not in any clear way. I assume that remote should be the
> ip of the host at the remote end of the tunnel, and local should be an
> IP address of a real interface on the this machine?
> 
> Am I missing something obvious here? At the time of the below
commands,
> br0 exists, but has no members, and eth0 is configured and up with ip
> 131.151.0.36/255.255.254.0. All other interfaces are down.
> 
> [root@bridge-rol ~]# ip link add gre3 type gretap remote 131.151.35.35
> local 131.151.0.36
> [root@bridge-rol ~]# brctl addif br0 gre3
> can't add gre3 to bridge br0: Invalid argument
> 
> [root@bridge-rol ~]# ip link del gre3
> [root@bridge-rol ~]# ip link add gre3 type gretap remote 131.151.35.35
> local 131.151.0.35
> [root@bridge-rol ~]# brctl addif br0 gre3
> can't add gre3 to bridge br0: Invalid argument
> 
> [root@bridge-rol ~]# ip link del gre3
> [root@bridge-rol ~]# ip link add gre3 type gretap remote 131.151.35.35
> local 10.151.0.35
> [root@bridge-rol ~]# brctl addif br0 gre3
> 
> [root@bridge-rol ~]# ip link del gre3
> [root@bridge-rol ~]# ip link add gre3 type gretap remote 131.151.35.35
> local 131.1.1.1
> [root@bridge-rol ~]# brctl addif br0 gre3
> can't add gre3 to bridge br0: Invalid argument
> 
> 
> 
> -- Nathan
> 
> ------------------------------------------------------------
> Nathan Neulinger                       nneul@mst.edu
> Missouri S&T Information Technology    (573) 612-1412
> System Administrator - Principal       KD0DMH
> 
> 
> > -----Original Message-----
> > From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> > Sent: Thursday, October 29, 2009 12:07 PM
> > To: Neulinger, Nathan
> > Subject: Re: How to use gretap with bridge?
> >
> > On Thu, Oct 29, 2009 at 10:41:18AM -0500, Neulinger, Nathan wrote:
> > > Is there some trick I'm missing to adding a gretap interface to a
> > > bridge?
> > >
> > > ip link add gre1 type gretap remote 131.151.0.36 local
131.151.0.35
> > > ip link set gre1 up
> > > brctl addbr br0
> > > brctl addif br0 gre1
> > >
> > > This results in an Invalid argument error when issuing the addif.
> > > Testing with latest fc12 2.6.31.5-96 kernel.
> > >
> > > Any suggestions?
> >
> > I can't reproduce this here.  Can you please try the latest
> > upstream kernel? If it still does the same thing, please post
> > to netdev@vger.kernel.org.
> >
> > Thanks!
> > --
> > Visit Openswan at http://www.openswan.org/
> > Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> > Home Page: http://gondor.apana.org.au/~herbert/
> > PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
