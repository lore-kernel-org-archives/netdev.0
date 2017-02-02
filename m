From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Wed, 1 Feb 2017 17:23:03 -0800
Message-ID: <20170202012301.GA74213@ast-mbp.thefacebook.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        tgraf@suug.ch, hannes@stressinduktion.org, jbenc@redhat.com,
        pshelar@ovn.org, dsa@cumulusnetworks.com, hadi@mojatatu.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33646 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751409AbdBBBXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 20:23:11 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so154810pfg.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 17:23:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:
>                     
> This provides the required vxlan bridging function but poses a
> scalability problem with using a separate vxlan netdev for each vni.

if I remember correctly this issue was the main reason David Ahern
put netdev on diet. Sounds like no more fun at netconf ;)

> Solution in this patch series:
> The Goal is to use a single vxlan device to carry all vnis similar
> to the vxlan collect metadata mode but additionally allowing the bridge
> and vxlan driver to carry all the forwarding information and also learn.
> This implementation uses the existing dst_metadata infrastructure to map
> vlan to a tunnel id.

ovs and/or bpf can do the same already, but sounds like the main reason is
to keep it integrated with bridge fdb to leverage your offload of bridge
fdb into hw asic, right?
If so, I guess, the extra complexity can be justified.
The question is how do you program hw ? Is there really 1 to 1 mapping
in the asics too? Or is it more flexible ?
I think most swith asics can do other tunnels too,
so can this vlan->vxlan 1 to 1 be generalized to cover different
types of tunnels that can be configured on the switch?
