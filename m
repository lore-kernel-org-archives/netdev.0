From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH net-next 2/5] liquidio VF vxlan
Date: Mon, 12 Dec 2016 17:11:55 -0800
Message-ID: <20161213011155.GA7791@felix.cavium.com>
References: <1481230848-2393-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1481230848-2393-3-git-send-email-rvatsavayi@caviumnetworks.com>
 <CAJ3xEMgrV4kjMY_SVJtk9VR85K7oSsSZGNQCi4UShogCKOq=hQ@mail.gmail.com>
 <DM3PR07MB21386696FCE7727BD9B3B48C81840@DM3PR07MB2138.namprd07.prod.outlook.com>
 <CAJ3xEMiMF3rMc1Ai0cuowNX=AkcJWQkVTqGx2QsHLriYVRr_tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0072.outbound.protection.outlook.com ([104.47.34.72]:11898
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752578AbcLMB2g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 20:28:36 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiMF3rMc1Ai0cuowNX=AkcJWQkVTqGx2QsHLriYVRr_tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <gerlitz.or@gmail.com> wrote on Sat [2016-Dec-10 05:46:13 -0800]:
> On Fri, Dec 9, 2016 at 12:42 AM, Vatsavayi, Raghu
> <Raghu.Vatsavayi@cavium.com> wrote:
> >> From: Or Gerlitz [mailto:gerlitz.or@gmail.com]
> >> On Thu, Dec 8, 2016 at 11:00 PM, Raghu Vatsavayi
> >> <rvatsavayi@caviumnetworks.com> wrote:
> 
> >>> Adds VF vxlan offload support.
> 
> >> What's the use case for that? a VM running a VTEP, isn't that part needs to
> >> run @ the host?
> 
> > Our HW can support offloads for VF which is required if we load it on Hypervisor.
> 
> 
> +       nctrl.ncmd.u64 = 0;
> +       nctrl.ncmd.s.cmd = command;
> +       nctrl.ncmd.s.more = vxlan_cmd_bit;
> +       nctrl.ncmd.s.param1 = vxlan_port;
> +       nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
> +       nctrl.wait_time = 100;
> +       nctrl.netpndev = (u64)netdev;
> +       nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
> +
> +       ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
> 
> 1. What happens if > 1 one VF runs this code, each with different
> port? who wins? is the result well defined?

There is neither race nor contention, but all VFs "win" (meaning they get
what they ask for) because the VxLAN UDP port can be set on a per VF basis.
So the result of the above case is:  for VFs running in the host (not in
VMs), each VF interface is a VTEP with a distinct UDP port for VxLAN.

> 2. does octnet_send_nic_ctrl_pkt() goes to sleep? this is disallowed here

No, it does not go to sleep.

Felix
