From: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH v2 02/15] usb: gadget: make config_item_type structures
 const
Date: Fri, 20 Oct 2017 10:02:46 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1710200857030.2090@hadrien>
References: <1508167134-6243-1-git-send-email-bhumirks@gmail.com> <1985905.z83BJQzMUS@avalon> <20171019140657.GA22233@lst.de> <6348630.r2z9ev4yl2@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        julia.lawall-L2FTfq7BK8M@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        knaack.h-Mmb7MZpHnFY@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, pmeerw-jW+XmwGofnusTnJN9+BGXg@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org, kishon-l0cyMroinI0@public.gmane.org,
        bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org, balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, jlbec-aKy9MeLSZ9dg9hUCZPvPmw@public.gmane.org,
        ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mfasheh-rOS7oXVqrJRBDgjK7y7TUQ@public.gmane.org,
        linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
To: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Return-path: <linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6348630.r2z9ev4yl2@avalon>
Sender: linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Thu, 19 Oct 2017, Laurent Pinchart wrote:

> Hi Christoph,
>
> On Thursday, 19 October 2017 17:06:57 EEST Christoph Hellwig wrote:
> > > Now we have 9 const instances of the config_item_type structure that are
> > > identical, with only the .ct_owner field set. Should they be all merged
> > > into a single structure ?
> >
> > I think that's a good idea.
> >
> > But I'm about to slurp up this whole series into my tree, how about making
> > that an incremental patch?
>
> I'm fine with that.
>
> Bhumika, would you like to submit an incremental patch, or should I do it ?

For various types, there seem to be a few hundred of these, eg:

static const struct hda_pcm_stream alc269_44k_pcm_analog_playback = {
        .rates = SNDRV_PCM_RATE_44100, /* fixed rate */
};

static const struct hda_pcm_stream alc269_44k_pcm_analog_capture = {
        .rates = SNDRV_PCM_RATE_44100, /* fixed rate */
};

Would it be desirable to remove them?  I guess one would have to check
that there are not any pointer equality checks on these values.  Would it
be useful to put a #define to keep the orignal names?

julia
