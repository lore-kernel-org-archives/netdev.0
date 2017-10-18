From: Yann Ylavic <ylavic.dev@gmail.com>
Subject: Re: [net-next V8 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Wed, 18 Oct 2017 12:47:40 +0200
Message-ID: <CAKQ1sVOuWerM7HrjR-0Yac+LtfBKb25QiQgmwMo-V_3OjAOyww@mail.gmail.com>
References: <150814913767.1806.3470498528707259987.stgit@firesoul>
 <150814916887.1806.4443991765779135803.stgit@firesoul> <CAKQ1sVMH-h36UWwuKhcVC=ZN+L=y3y3apayye_yKYKXTbqMGTQ@mail.gmail.com>
 <20171018103807.367e91ee@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com, ast@fiberby.dk,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:52019 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934166AbdJRKrm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 06:47:42 -0400
Received: by mail-qt0-f194.google.com with SMTP id h4so9583221qtk.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 03:47:41 -0700 (PDT)
In-Reply-To: <20171018103807.367e91ee@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 10:38 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Wed, 18 Oct 2017 09:45:59 +0200 Yann Ylavic <ylavic.dev@gmail.com> wrote:
>
>> On Mon, Oct 16, 2017 at 12:19 PM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > +
>> > +       /* Notice returns -EPERM on if map size is larger than memlock limit */
>> > +       ret = bpf_map_precharge_memlock(cmap->map.pages);
>> > +       if (ret) {
>> > +               err = ret;
>> > +               goto free_cmap;
>> > +       }
>> > +
>> > +       /* A per cpu bitfield with a bit per possible CPU in map  */
>> > +       cmap->flush_needed = __alloc_percpu(cpu_map_bitmap_size(attr),
>> > +                                           __alignof__(unsigned long));
>> > +       if (!cmap->flush_needed)
>> > +               goto free_cmap;
>> > +
>> > +       /* Alloc array for possible remote "destination" CPUs */
>> > +       cmap->cpu_map = bpf_map_area_alloc(cmap->map.max_entries *
>> > +                                          sizeof(struct bpf_cpu_map_entry *),
>> > +                                          cmap->map.numa_node);
>> > +       if (!cmap->cpu_map)
>>
>> ret = -ENOMEM; ?
>
> Did you notice that "err" already is = -ENOMEM at this point?

My bad, I was confused by the use of "ret"...

>
>
>> > +               goto free_percpu;
>> > +
>> > +       return &cmap->map;
>> > +free_percpu:
>> > +       free_percpu(cmap->flush_needed);
>> > +free_cmap:
>> > +       kfree(cmap);
>> > +       return ERR_PTR(err);

.. while actually "err" is returned.
Sorry for wasting your time.

>> > +}
>>
>>
>> Regards,
>> Yann.
