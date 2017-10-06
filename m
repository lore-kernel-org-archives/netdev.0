From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V4 PATCH 2/5] bpf: XDP_REDIRECT enable use of cpumap
Date: Fri, 6 Oct 2017 17:45:52 +0200
Message-ID: <20171006174552.34b6b8ba@redhat.com>
References: <150711858281.9499.7767364427831352921.stgit@firesoul>
        <150711863012.9499.383645968070658124.stgit@firesoul>
        <59D60505.2040004@iogearbox.net>
        <20171006131748.75185f65@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36978 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751323AbdJFPqD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 11:46:03 -0400
In-Reply-To: <20171006131748.75185f65@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Oct 2017 13:17:48 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> > > +static void *__xdp_map_lookup_elem(struct bpf_map *map, u32 index)
> > > +{
> > > +	switch (map->map_type) {
> > > +	case BPF_MAP_TYPE_DEVMAP:
> > > +		return __dev_map_lookup_elem(map, index);
> > > +	case BPF_MAP_TYPE_CPUMAP:
> > > +		return __cpu_map_lookup_elem(map, index);
> > > +	default:
> > > +		return NULL;
> > > +	}    
> > 
> > Should we just have a callback and instead of the above use
> > map->ptr_lookup_elem() (or however we name it) ... lot of it
> > is pretty much the same logic as with devmap.  
> 
> We could extend struct bpf_map *map with such a callback, I was just
> afraid that this would be too invasive.
> 
> Performance wise, I don't thinks will hurt too much.
> http://www.cipht.net/2017/10/03/are-jump-tables-always-fastest.html

Looking at the code, I would like to postpone this callback work until
after this patchset is merged.  As this work will also touch devmap +
sockmap.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
