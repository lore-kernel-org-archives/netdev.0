From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH V2 1/1] net: cdc_ncm: Reduce memory use when kernel memory low
Date: Fri, 30 Jun 2017 20:03:40 +0200
Message-ID: <8760fds683.fsf@miraculix.mork.no>
References: <1498682129-9129-1-git-send-email-jim_baxter@mentor.com>
        <1498682129-9129-2-git-send-email-jim_baxter@mentor.com>
        <87bmp5s7dx.fsf@miraculix.mork.no>
        <356bdf94-813d-94ef-4dc3-a582fe5b3343@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Oliver Neukum <oliver@neukum.org>,
        David Laight <David.Laight@ACULAB.COM>
To: "Baxter\, Jim" <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <356bdf94-813d-94ef-4dc3-a582fe5b3343@mentor.com> (Jim Baxter's
        message of "Fri, 30 Jun 2017 18:53:56 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Baxter, Jim" <jim_baxter@mentor.com> writes:

> I tested this with printk's to show when the low memory code was triggered
> and the value of ctx->tx_low_mem_val and ctx->tx_low_mem_max_cnt.
> I created a workqueue that slowly used up the atomic memory until the
> code is triggered.
>
> I could add debug prints, though I have noticed that cdc_ncm_fill_tx_fram=
e()
> does not currently have any debug prints do you think this is because it =
can be
> called in an atomic context and I think debug messages if enabled could c=
ause
> too great a delay?

Yes, I guess you're right.  Maybe count the number of failed allocations
and export it along with the other driver private counters?  Or export
the tx_curr_size as a sysfs attribute? Or both?

Just an idea...  I don't expect to see this code ever being hit on my
systems :-)



Bj=C3=B8rn
