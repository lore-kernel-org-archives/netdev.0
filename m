From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH net-next 1/2] wireless: Remove casts of void *
Date: Tue, 14 Jun 2011 19:43:15 +0200
Message-ID: <201106141943.15887.chunkeey@googlemail.com>
References: <cover.1308024069.git.joe@perches.com> <4DF78CEC.70409@gnu.org> <1308069831.21026.9.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, "Wey-Yi Guy" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308069831.21026.9.camel@Joe-Laptop>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 June 2011 18:43:51 Joe Perches wrote:
> On Tue, 2011-06-14 at 12:31 -0400, Pavel Roskin wrote:
> > On 06/14/2011 12:02 AM, Joe Perches wrote:
> > >   		/* Get the message ID */
> > > -		msg_id = (__be16 *) ((void *) htc_hdr +
> > > -				     sizeof(struct htc_frame_hdr));
> > > +		msg_id = (void *)htc_hdr + sizeof(struct htc_frame_hdr);
> > I would never do stuff like this without verifying by sparse that no 
> > warnings are introduced.
> 
> I did that.  I believe there are no new warnings.
> 
> > Sparse warnings should be avoided to keep sparse checks useful. 
> > Otherwise, important warnings would drown in the noise.
> 
> $ make allyesconfig
> $ git log -1 --pretty=oneline drivers/net/wireless/ath/ath9k/htc_hst.c
> 337c22b774ff7f007b90b266b25c9a33ff555c48 wireless: Remove casts of void *
> $ make C=2 drivers/net/wireless/ath/ath9k/htc_hst.o

Just a quick FYI: To perform endianness checks, you may define __CHECK_ENDIAN__:

make C=2 CF="-D__CHECK_ENDIAN__"

[Although, it doesn't look like your patch introduced any new endianness
problems]

Regards,
	Chr
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
