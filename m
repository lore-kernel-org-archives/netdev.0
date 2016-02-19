From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/3] net: netcp: rework the code for get/set sw_data in dma desc
Date: Fri, 19 Feb 2016 23:25:11 +0100
Message-ID: <4850949.nFTN7kbEd4@wuerfel>
References: <1455904724-17952-1-git-send-email-m-karicheri2@ti.com> <3256728.DYdlef6xAF@wuerfel> <56C79585.1090905@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C79585.1090905@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 February 2016 17:21:57 Murali Karicheri wrote:
> >>              get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
> >> -            get_sw_data((u32 *)&buf_ptr, &buf_len, ndesc);
> >> +            /* warning!!!! We are retrieving the virtual ptr in the sw_data
> >> +             * field as a 32bit value. Will not work on 64bit machines
> >> +             */
> >> +            buf_ptr = (void *)GET_SW_DATA0(ndesc);
> >> +            buf_len = (int)GET_SW_DATA1(desc);
> > 
> > I would have abstracted the retrieval of a pointer again,
> > and added the comment in the helper function once, it doesn't
> > really need to be duplicated everywhere.
> > 
> Arnd,
> 
> I thought about it to add it to the API. API currently set buffer
> and ptr. It would be an issue only if store/retrieve ptr in/from the sw_data.
> So for the comment to be really useful to someone who is changing the code,
> doesn't it make sense to add it at the point of invocation as done in this
> patch? No?
> 

Up to you, it was just an idea and you have my Ack either way.

	Arnd
