From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net, mellanox mlx4 Fix compile warnings
Date: Mon, 16 Sep 2013 09:59:41 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B733A@saturn3.aculab.com>
References: <1379075438-20240-1-git-send-email-prarit@redhat.com><CAJZOPZLt8G8MsPxiRNySex=izThR74bXcnWTmWB2wjPys09_ig@mail.gmail.com> <20130915091400.49f90bc4@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Prarit Bhargava" <prarit@redhat.com>, <netdev@vger.kernel.org>,
	"Doug Ledford" <dledford@redhat.com>,
	"Amir Vadai" <amirv@mellanox.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: "Jack Morgenstein" <jackm@dev.mellanox.co.il>,
	"Or Gerlitz" <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53838 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751075Ab3IPJBN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 05:01:13 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27101-05 for <netdev@vger.kernel.org>;
 Mon, 16 Sep 2013 10:01:10 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130915091400.49f90bc4@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sat, 14 Sep 2013 22:10:19 +0300
> Or Gerlitz <or.gerlitz@gmail.com> wrote:
> 
> > > +       struct res_cq *uninitialized_var(cq);
> > >
> > >         err = cq_res_start_move_to(dev, slave, cqn,
> > > RES_CQ_ALLOCATED, &cq);
> 
> I have no objection. However, I don't know if the compiler is being too
> clever here or too stupid.  The cq variable is initialized in
> cq_res_start_move_to(), but the compiler is ignoring this -- or maybe
> it is simply not assuming that cq will in fact be
> initialized by the called procedure?

Possibly cq_res_start_move_to() got inlined - and the analysis
of the inlined code found a path where it wasn't initialised.

Most likely one of the paths where the return value is non-zero.

> In any event, this change cannot hurt.

It could hide a real 'used but not initialised' error later on...

	David
