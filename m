From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: XDP question - how much can BPF change in xdp_buff?
Date: Mon, 31 Oct 2016 18:31:30 +0000
Message-ID: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0067.outbound.protection.outlook.com ([104.47.42.67]:2410
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S944528AbcJaSbc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 14:31:32 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So I've [finally] started looking into implementing XDP
for qede, and there's one thing I feel like I'm missing in
regard to XDP_TX - what's the guarantee/requirement
that the bpf program isn't going to transmute some fields
of the rx packet in a way that would prevent the forwarding?

E.g., can a BPF change the TCP payload of an incoming packet
without correcting its TCP checksum, and then expect the
driver to transmit it [via XDP_TX]? If not, how is this enforced [if at all=
]?

[Looked at samples/bpf/xdp2_kern.c which manipulates the
UDP header; so I'm not certain what prevents it from doing
the same when checksum modifications would be required]


    =
