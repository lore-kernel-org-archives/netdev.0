From: Christoph Lameter <cl@linux.com>
Subject: RE: Designing a safe RX-zero-copy Memory Model for Networking
Date: Wed, 14 Dec 2016 13:43:43 -0600 (CST)
Message-ID: <alpine.DEB.2.20.1612141342080.23516@east.gentwo.org>
References: <20161205153132.283fcb0e@redhat.com> <20161212083812.GA19987@rapoport-lnx> <20161212104042.0a011212@redhat.com> <20161212141433.GB19987@rapoport-lnx> <584EB8DF.8000308@gmail.com> <20161212181344.3ddfa9c3@redhat.com> <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <8aea213f-2739-9bd3-3a6a-668b759336ae@stressinduktion.org> <alpine.DEB.2.20.1612141059020.20959@east.gentwo.org> <063D6719AE5E284EB5DD2968C1650D6DB023FA6E@AcuExch.aculab.com>
Content-Type: text/plain; charset=US-ASCII
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        =?ISO-8859-15?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
        "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Kalman Meth <METH@il.ibm.com>,
        Vladislav Yasevich <vyasevi
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-04v.sys.comcast.net ([69.252.207.36]:60613 "EHLO
        resqmta-ch2-04v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751674AbcLNTnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 14:43:47 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB023FA6E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Dec 2016, David Laight wrote:

> If the kernel is doing ANY validation on the frames it must copy the
> data to memory the application cannot modify before doing the validation.
> Otherwise the application could change the data afterwards.

The application is not allowed to change the data after a work request has
been submitted to send the frame. Changes are possible after the
completion request has been received.

The kernel can enforce that by making the frame(s) readonly and thus
getting a page fault if the app would do such a thing.
