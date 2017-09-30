From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 2/5] bpf: Add map_name to bpf_map_info
Date: Fri, 29 Sep 2017 19:35:18 -0700
Message-ID: <20170930023518.bmc6dbpnz27wunod@kafai-mbp>
References: <20170927213756.1254938-1-kafai@fb.com>
 <20170927213756.1254938-3-kafai@fb.com>
 <20170929190746.322df52d@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41780 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752677AbdI3Cfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 22:35:38 -0400
Content-Disposition: inline
In-Reply-To: <20170929190746.322df52d@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 30, 2017 at 02:07:46AM +0000, Jakub Kicinski wrote:
> Hi Martin!
> 
> On Wed, 27 Sep 2017 14:37:53 -0700, Martin KaFai Lau wrote:
> > diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> > index 33ccc474fb04..252f4bc9eb25 100644
> > --- a/include/linux/bpf.h
> > +++ b/include/linux/bpf.h
> > @@ -56,6 +56,7 @@ struct bpf_map {
> >  	struct work_struct work;
> >  	atomic_t usercnt;
> >  	struct bpf_map *inner_map_meta;
> > +	u8 name[BPF_OBJ_NAME_LEN];
> 
> Any reason not to use plain char?  I was looking at adding names to
> bpftool and:
Happy to have early user :)

It was mostly due to my early idea on treating the name as
a blob without much char checking, which was then trashed
but did not reflect that here.

I will make a followup patch later.
> 
> map.c: In function ‘show_map_close’:
> map.c:386:13: warning: pointer targets in passing argument 1 of ‘strlen’ differ in signedness [-Wpointer-sign]
>   if (strlen(info->name))
>              ^~~~
> In file included from map.c:43:0:
> /usr/include/string.h:399:15: note: expected ‘const char *’ but argument is of type ‘__u8 * {aka unsigned char *}’
>  extern size_t strlen (const char *__s)
>                ^~~~~~
> >  };
> >  
> >  /* function argument constraints */
> 
