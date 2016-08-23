From: Anton Danilov <littlesmilingcloud@gmail.com>
Subject: Linux router kernel configuration
Date: Tue, 23 Aug 2016 23:28:19 +0300
Message-ID: <E1bcIJ1-0004T6-Do@danilov>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:34582 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755956AbcHWU2W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:28:22 -0400
Received: by mail-lf0-f67.google.com with SMTP id k135so8308211lfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:28:21 -0700 (PDT)
Received: from danilov ([87.244.6.228])
        by smtp.gmail.com with ESMTPSA id m62sm1199672lfe.44.2016.08.23.13.28.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 13:28:19 -0700 (PDT)
Received: from danilov by danilov with local (Exim 4.84_2)
        (envelope-from <littlesmilingcloud@gmail.com>)
        id 1bcIJ1-0004T6-Do
        for netdev@vger.kernel.org; Tue, 23 Aug 2016 23:28:19 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello everyone.

I'm working in a small ISP company, and we're using x86 servers under debian as core and border routers.

The pair of core routers (active-backup redundancy scheme) are the dual-socket servers with Xeon E5-2637 v2 CPUs and one 82599EB dual-port 10G NIC. Tasks of these routers: traffic shaping (HTB+pfifo with u32 hashing classifier), content filtering (ipset + nfqueue + suricata) and some blocking of access with ipset address sets. Average duplex traffic is couple of gigabits per second / several hundreds of kpps. Currently we're using the custom configurated 3.10 kernel on these servers. 

I have several questions about kernel configuration in which I'm stuck or doubt:
1. Kernel version. What is the kernel better for these tasks at now? I'm think about usage of latest LTS kernel (4.4).
1. Timers subsystem: periodic ticks / idle dynticks / full dynticks. Are there some recomendations? Currently I'm using periodic ticks with 1000HZ frequency. Maybe is there better choice?
2. Preemption model. I'm using the no forced preemption on routers.
3. Power management. Should I disable the processor power management features in kernel config or use the kernel cmd line boot options like processor.max_cstate = 0 and intel_idle.max_cstate = 0?
4. Hyper-threading usage. I've disabled it in the bios to avoid a unefficient cache usage. But maybe someone have opposite view on this feature.

Thanks for your attention and advices.

---

With best regards
Anton Danilov mailto://littlesmilingcloud@gmail.com
