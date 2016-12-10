From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/5] liquidio VF vxlan
Date: Sat, 10 Dec 2016 15:46:13 +0200
Message-ID: <CAJ3xEMiMF3rMc1Ai0cuowNX=AkcJWQkVTqGx2QsHLriYVRr_tA@mail.gmail.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1481230848-2393-3-git-send-email-rvatsavayi@caviumnetworks.com>
 <CAJ3xEMgrV4kjMY_SVJtk9VR85K7oSsSZGNQCi4UShogCKOq=hQ@mail.gmail.com> <DM3PR07MB21386696FCE7727BD9B3B48C81840@DM3PR07MB2138.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
To: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36065 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcLJNqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 08:46:15 -0500
Received: by mail-oi0-f66.google.com with SMTP id u15so5696443oie.3
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2016 05:46:14 -0800 (PST)
In-Reply-To: <DM3PR07MB21386696FCE7727BD9B3B48C81840@DM3PR07MB2138.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 9, 2016 at 12:42 AM, Vatsavayi, Raghu
<Raghu.Vatsavayi@cavium.com> wrote:
>> From: Or Gerlitz [mailto:gerlitz.or@gmail.com]
>> On Thu, Dec 8, 2016 at 11:00 PM, Raghu Vatsavayi
>> <rvatsavayi@caviumnetworks.com> wrote:

>>> Adds VF vxlan offload support.

>> What's the use case for that? a VM running a VTEP, isn't that part needs to
>> run @ the host?

> Our HW can support offloads for VF which is required if we load it on Hypervisor.


+       nctrl.ncmd.u64 = 0;
+       nctrl.ncmd.s.cmd = command;
+       nctrl.ncmd.s.more = vxlan_cmd_bit;
+       nctrl.ncmd.s.param1 = vxlan_port;
+       nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+       nctrl.wait_time = 100;
+       nctrl.netpndev = (u64)netdev;
+       nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+       ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);

1. What happens if > 1 one VF runs this code, each with different
port? who wins? is the result well defined?

2. does octnet_send_nic_ctrl_pkt() goes to sleep? this is disallowed here

Or.
