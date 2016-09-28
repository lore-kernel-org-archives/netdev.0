From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH v2 net] net: skbuff: skb_vlan_push: Fix wrong unwinding
 of skb->data after __vlan_insert_tag call
Date: Wed, 28 Sep 2016 20:11:36 +0300
Message-ID: <20160928201136.1600ac65@halley>
References: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>
        <57EB9BE0.4080903@iogearbox.net>
        <20160928145644.662ecc04@pixies>
        <57EBD71A.90104@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34845 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932856AbcI1RLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 13:11:43 -0400
Received: by mail-wm0-f41.google.com with SMTP id l132so247255845wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 10:11:42 -0700 (PDT)
In-Reply-To: <57EBD71A.90104@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2016 16:43:38 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:
> > (1) suppose upon entry we have
> >
> >      DA,SA,0x8100,TCI,0x0800,
> >      ^                ^
> >      mac_hdr          data
> >
> > initial offset is 18, and after current unwinding code we'll get  
> 
> You mean data points after the 0x0800, right?

Sorry. Yes, exactly as you say. Initially 18 bytes ahead:

    DA,SA,0x8100,TCI,0x0800,
    ^                       ^
    mac_hdr                 data
