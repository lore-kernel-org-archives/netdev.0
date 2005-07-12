From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 13:56:55 -0700
Message-ID: <200507122057.j6CKv1KP011554@guinness.s2io.com>
References: <20050712202754.GA10768@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <jgarzik@pobox.com>, <netdev@oss.sgi.com>,
        <ravinandan.arakali@neterion.com>, <rapuru.sriram@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Christoph Hellwig'" <hch@infradead.org>,
        <raghavendra.koushik@neterion.com>
In-Reply-To: <20050712202754.GA10768@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org] 
> Sent: Tuesday, July 12, 2005 1:28 PM
> To: raghavendra.koushik@neterion.com
> Cc: jgarzik@pobox.com; netdev@oss.sgi.com; 
> ravinandan.arakali@neterion.com; 
> leonid.grossman@neterion.com; rapuru.sriram@neterion.com
> Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
> 
> > 3. Enable two-buffer mode(for Rx path) automatically for SGI
> >    systems. This improves Rx performance dramatically on 
> >    SGI systems.
> 
> > +/* Enable 2 buffer mode by default for SGI system */ #ifdef 
> > +CONFIG_IA64_SGI_SN2 #define CONFIG_2BUFF_MODE #endif
> 
> this enabled it only on kernel that are built to only run on 
> SN2 hardware, which is completely useless in practice.  
> Besides that defining a CONFIG_ symbol from source files is a 
> big no-go.
> 
> What exactly is the 2buff mode, and more specific what are 
> the downsides of  enabling it on non-SGI hardware?

In short, this is one of the ASIC modes where headers and payload are
separated by the hardware, and placed in separate receive buffers. (More
details are in the ASIC programming manual that is posted on ns1.s2io.com).
On SGI platforms, the two buffer mode results in a significant rx
performance boost since it allows to achieve both aligned transfers on the
bus and aligned data copies. 
It has been tested on Altix systems quite a bit (the card is OEMed and
shipped by SGI).
On other platforms, we haven't seen significant benefits from header
separation modes (unless they are combined with different features, which is
another story), and we decided not to introduce an extra bus transfer unless
it is clearly justified.
Also, the feature has not been sufficiently tested on other platforms,
For these reasons, it is left as a feature that's specific to SGI chipset -
but it is really beneficial there.

Leonid



> 
> 
