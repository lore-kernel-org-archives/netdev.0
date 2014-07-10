From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/5] SCTP updates
Date: Thu, 10 Jul 2014 09:02:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726FBA0@AcuExch.aculab.com>
References: <20140708111408.GA23026@hmsreliant.think-freely.org>
 <53BBFAA6.80408@redhat.com>
 <20140708144127.GB23026@hmsreliant.think-freely.org>
 <53BD1211.4080504@redhat.com>
 <20140709104958.GA3784@hmsreliant.think-freely.org>
 <53BD4363.70306@redhat.com> <20140709151354.GA5250@localhost.localdomain>
 <53BD6167.1030000@gmail.com> <20140709154428.GD5250@localhost.localdomain>
 <53BD6EB7.7070302@gmail.com>
 <20140709183508.GB14509@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"geirola@gmail.com" <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Neil Horman' <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44642 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752048AbaGJJD7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 05:03:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23645-01 for <netdev@vger.kernel.org>;
 Thu, 10 Jul 2014 10:03:51 +0100 (BST)
In-Reply-To: <20140709183508.GB14509@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman
...
> > No there is not direct overlap between the two.  However, as Michael pointed out,
> > there is a new option to control SCTP_RCVINFO.  So would could add a deprecation
> > warning to the over SCTP_EVENTS option and carry SCTP_SNDRCVINFO with it.
> > Once SCTP_EVENTS goes away so can SCTP_SNDRCVINFO.
> >
> Ok, so we should still consider deprecation warnings then.  Daniel, what about
> ratelimited warnings with pids included then?

Can you defer any deprecation warnings for a few kernel versions?
This gives time for applications to be recoded.
Including argv[0] (even just the exec-time value) is much more use than the pid.

Actually this is 'right PITA' for an application.
A program binary that needs to work with old and new kernels will have to
try the new option, and if it fails fall back to the old one, and then
conditionally create/inspect the cmsg data.
I can't actually imagine anyone bothering!

Our sctp code is actually in a kernel module, so we can look at the kernel
version when (part of) the driver is compiled on the target system.

	David
