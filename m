From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 14:00:52 -0700
Message-ID: <000a01c58724$ca41a7c0$4f10100a@pc.s2io.com>
References: <20050712.133404.52118192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <raghavendra.koushik@neterion.com>, <jgarzik@pobox.com>,
        <netdev@oss.sgi.com>, <leonid.grossman@neterion.com>,
        <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'David S. Miller'" <davem@davemloft.net>, <hch@infradead.org>
In-Reply-To: <20050712.133404.52118192.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The two-buffer mode was added as a configurable option
to Kconfig file several months ago. Hence the macro
is CONFIG_2BUFF_MODE.

The two-buffer receive mode involves two buffers (128 byte
aligned) for each packet. This mode drastically increases
performance on SGI platforms and hence enabled only for
these platforms. On other platforms, there's no difference
compared to one-buffer mode but the added complexity and
extra memory allocated does not make it worthwhile to
enable this mode for non-SGI platforms. Also, most of 
our QA cycle on non-SGI platforms has been done with
one-buffer mode.

Thanks,
Ravi


> > +/* Enable 2 buffer mode by default for SGI system */
> > +#ifdef CONFIG_IA64_SGI_SN2
> > +#define CONFIG_2BUFF_MODE
> > +#endif
> 
> this enabled it only on kernel that are built to only run on SN2
> hardware, which is completely useless in practice.  Besides that defining
> a CONFIG_ symbol from source files is a big no-go.

Yes, do this in the Kconfig file instead.
