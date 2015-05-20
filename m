From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 09/10] pktgen: add sample script pktgen_sample03_burst_single_flow.sh
Date: Wed, 20 May 2015 14:33:42 -0700
Message-ID: <CAHA+R7NVB8EaiSMQeEw9atPy_7hz0YrBSazMK9zwDEJC5CpB2w@mail.gmail.com>
References: <20150519213326.9070.18264.stgit@ivy>
	<20150519213639.9070.50273.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Robert Olsson <robert@herjulf.se>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37252 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbbETVdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 17:33:43 -0400
Received: by wibt6 with SMTP id t6so74470118wib.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 14:33:42 -0700 (PDT)
In-Reply-To: <20150519213639.9070.50273.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 19, 2015 at 2:36 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> +# Threads are specified with parameter -t value in $THREADS
> +for ((thread = 0; thread < $THREADS; thread++)); do
> +    dev=${DEV}@${thread}
> +
> +    # Add remove all other devices and add_device $dev to thread
> +    pg_thread $thread "rem_device_all"
> +    pg_thread $thread "add_device" $dev
> +
> +    # Base config
> +    pg_set $dev "flag QUEUE_MAP_CPU"
> +    pg_set $dev "count $COUNT"
> +    pg_set $dev "clone_skb $CLONE_SKB"
> +    pg_set $dev "pkt_size $PKT_SIZE"
> +    pg_set $dev "delay $DELAY"
> +    pg_set $dev "flag NO_TIMESTAMP"
> +
> +    # Destination
> +    pg_set $dev "dst_mac $DST_MAC"
> +    pg_set $dev "dst $DEST_IP"
> +
> +    # Setup burst, for easy testing -b 0 disable bursting
> +    # (internally in pktgen default and minimum burst=1)
> +    if [[ ${BURST} != 0 ]]; then


Nit: probably you mean: [[ ${BURST} -ne 0 ]]

> +       pg_set $dev "burst $BURST"
> +    else
> +       info "$dev: Not using burst"
> +    fi
> +done
