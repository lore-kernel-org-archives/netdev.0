From: "Raghavendra Koushik" <raghavendra.koushik@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Thu, 14 Oct 2004 11:33:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410141833.i9EIXI39018452@guinness.s2io.com>
References: <416E9550.4060001@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, <netdev@oss.sgi.com>,
        <leonid.grossman@s2io.com>, <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>, <ravinandan.arakali@s2io.com>
In-Reply-To: <416E9550.4060001@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Thursday, October 14, 2004 8:04 AM
> To: ravinandan.arakali@s2io.com
> Cc: 'Francois Romieu'; netdev@oss.sgi.com; leonid.grossman@s2io.com;
> raghavendra.koushik@s2io.com; rapuru.sriram@s2io.com
> Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
> 
> no objections but two comments:
> 
> 1) can this not be done with SKB fragments?
> 
To acheve what is required, the H/W still has to split the Rx'ed frame into
2 parts. By implementing this through the SKB fragments method, the only
thing we avoid is usage of ba_0 and ba_1 fields, but note that none of these
are allocated or freed in fast path. They are all pre-allocated buffers
(along with the Rx descriptors) and hence won't hit the Rx side performance.
Also by pulling down the eth_type_trans implementation partially into the
driver any kind of copy during Rx is also avoided.  


> 2) the following code needlessly uses GFP_ATOMIC:
> 
> > +                               ba = &nic->ba[i][j][k];
> > +
> > +                               ba->ba_0_org = (void *) kmalloc
> > +                                   (BUF0_LEN + ALIGN_SIZE, GFP_ATOMIC);
> 
> and there is another example just a bit down from that one.
