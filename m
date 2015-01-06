From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v1 01/11] net: flow_table: create interface for
 hw match/action tables
Date: Tue, 6 Jan 2015 11:05:16 +0900
Message-ID: <20150106020514.GA24057@vergenet.net>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
 <20141231194544.31070.30335.stgit@nitbit.x32>
 <20150104111238.GD15305@casper.infradead.org>
 <54AADEFF.3090306@gmail.com>
 <54AB303E.3000601@gmail.com>
 <20150106010942.GD14077@vergenet.net>
 <54AB381E.3010009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, netdev@vger.kernel.org, davem@davemloft.net,
	andy@greyhouse.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:43373 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101AbbAFCF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 21:05:29 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so30025476pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 18:05:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54AB381E.3010009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2015 at 05:19:26PM -0800, John Fastabend wrote:
> On 01/05/2015 05:09 PM, Simon Horman wrote:
> >On Mon, Jan 05, 2015 at 04:45:50PM -0800, John Fastabend wrote:
> >>[...]
> >>
> >>>>>+/**
> >>>>>+ * @struct net_flow_field_ref
> >>>>>+ * @brief uniquely identify field as header:field tuple
> >>>>>+ */
> >>>>>+struct net_flow_field_ref {
> >>>>>+    int instance;
> >>>>>+    int header;
> >>>>>+    int field;
> >>>>>+    int mask_type;
> >>>>>+    int type;
> >>>>>+    union {    /* Are these all the required data types */
> >>>>>+        __u8 value_u8;
> >>>>>+        __u16 value_u16;
> >>>>>+        __u32 value_u32;
> >>>>>+        __u64 value_u64;
> >>>>>+    };
> >>>>>+    union {    /* Are these all the required data types */
> >>>>>+        __u8 mask_u8;
> >>>>>+        __u16 mask_u16;
> >>>>>+        __u32 mask_u32;
> >>>>>+        __u64 mask_u64;
> >>>>>+    };
> >>>>>+};
> >>>>
> >>>>Does it make sense to write this as follows?
> >>>
> >>>Yes. I'll make this update it helps make it clear value/mask pairs are
> >>>needed.
> >>>
> >>>>
> >>>>union {
> >>>>         struct {
> >>>>                 __u8 value_u8;
> >>>>                 __u8 mask_u8;
> >>>>         };
> >>>>         struct {
> >>>>                 __u16 value_u16;
> >>>>                 __u16 mask_u16;
> >>>>         };
> >>>>         ...
> >>>>};
> >>
> >>Another thought is to pull this entirely out of the structure and hide
> >>it from the UAPI so we can add more value/mask types as needed without
> >>having to spin versions of net_flow_field_ref. On the other hand I've
> >>been able to fit all my fields in these types so far and I can't think
> >>of any additions we need at the moment.
> >
> >FWIW, I think it would be cleaner to break both field_ref and action_args
> >out into attributes and not expose the structures to user-space. But
> >perhaps there is an advantage to dealing with structures directly that
> >I am missing.
> >
> 
> I  came to the same conclusion just now as well. I'm reworking it now
> for v2.

Thanks.

BTW, I think there are a few problems with net_flow_put_flow_action().

I am not quite to the bottom of it but it seems that:
* It loops over a->args[i] and then calls net_flow_put_act_types()
  which performs a similar loop. This outer-loop appears to be incorrect.
* It passes a[i].args instead of a->args[i] to net_flow_put_act_types()

I can post a fix once I've got it working to my satisfaction.
But if you are reworking that code anyway perhaps it is easier for
you to handle it then.
