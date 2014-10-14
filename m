From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1 linux-next] zd1201: replace kmalloc/memset by kzalloc
Date: Tue, 14 Oct 2014 20:08:34 +0200
Message-ID: <87iojm8qxp.fsf@nemi.mork.no>
References: <1413304831-7203-1-git-send-email-fabf@skynet.be>
	<1413306955.3269.30.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413306955.3269.30.camel@joe-AO725> (Joe Perches's message of
	"Tue, 14 Oct 2014 10:15:55 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> And does this really need to be alloc'd?

Yes, it does. It is used as a transfer_buffer in usb_fill_bulk_urb() an=
d
must be "suitable for DMA".  From include/linux/usb.h:

/**
 * struct urb - USB Request Block
=2E.
 * @transfer_buffer:  This identifies the buffer to (or from) which the=
 I/O
 *      request will be performed unless URB_NO_TRANSFER_DMA_MAP is set
 *      (however, do not leave garbage in transfer_buffer even then).
 *      This buffer must be suitable for DMA; allocate it with
 *      kmalloc() or equivalent.  For transfers to "in" endpoints, cont=
ents
 *      of this buffer will be modified.  This buffer is used for the d=
ata
 *      stage of control transfers.



Bj=C3=B8rn
