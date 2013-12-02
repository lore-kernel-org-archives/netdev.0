From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors withbatman-adv
Date: Mon, 2 Dec 2013 13:10:12 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7453@saturn3.aculab.com>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <529A46C4.9090906@meshcoding.com> <20131130230518.GC16735@n2100.arm.linux.org.uk> <529A8276.9060002@meshcoding.com> <529B47AA.8060403@meshcoding.com> <20131201171309.GD16735@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B7451@saturn3.aculab.com> <529C8226.2040000@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "The list for a Better Approach To Mobile Ad-hoc Networking"
	<b.a.t.m.a.n@lists.open-mesh.org>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Antonio Quartulli" <antonio@meshcoding.com>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59706 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751478Ab3LBNMa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 08:12:30 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24974-07 for <netdev@vger.kernel.org>;
 Mon,  2 Dec 2013 13:12:26 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <529C8226.2040000@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Antonio Quartulli
> On 02/12/13 11:24, David Laight wrote:
> > ...
> >> The only solutions are: use the GCC packed attribute, redesign
> >> the structures...
> >
> > It is probably enough to mark the inner structure containing the
> > three byte fields 'packed'. Marking it aligned(1) might also have
> > the desired effect. The outer structure should then be ok. But
> > would need to use a specially named attribute so it doesn't get
> > removed.
> 
> This may work with the structures I reported in a previous email, but
> it is not a good solution for us because we have other more complex
> substructs that cannot be packed that way.

You really don't want to have structures that need to be (say) 7 bytes
long and contain a 32bit value that will always be correctly aligned.

IIRC adding __attribute__((aligned(1))) to a structure isn't the same
as marking it 'packed' - it doesn't normally reduce the alignment
for structures (but can be used to force a reduced alignment on a
structure member - eg a 4byte aligned 64bit integer).

I don't have an arm compiler handy.

> I think we will simply duplicate the members and avoid substructs in
> our packets.

Can be easiest...


	David
