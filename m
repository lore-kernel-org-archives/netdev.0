From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 00:20:59 +0200
Message-ID: <1492640459.22185.7.camel@sipsolutions.net>
References: <1492637460.22185.6.camel@sipsolutions.net>
         (sfid-20170419_233114_060429_CAFE85B8)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:46260 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935662AbdDSWVE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 18:21:04 -0400
In-Reply-To: <1492637460.22185.6.camel@sipsolutions.net> (sfid-20170419_233114_060429_CAFE85B8)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-19 at 23:31 +0200, Johannes Berg wrote:
> Hi Alexei, Daniel,
> 
> I'm looking at adding the __wifi_sk_buff I talked about, and I notice
> that it uses CB space to store data_end. Unfortunately, in a lot of
> cases, we don't have any CB space to spare in wifi.

I guess I can work around this, would this seem reasonable?

 struct bpf_skb_data_end {
        struct qdisc_skb_cb qdisc_cb;
-       void *data_end;
+       /*
+        * The alignment here is for mac80211, since that doesn't use
+        * a pointer but a u64 value and needs to save/restore that
+        * across running its BPF programs.
+        */
+       void *data_end __aligned(sizeof(u64));
 };

johannes
