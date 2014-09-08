From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next 00/13] introduce rocker switch driver with
 openvswitch hardware accelerated datapath
Date: Mon, 8 Sep 2014 14:54:13 +0100
Message-ID: <20140908135413.GA5995@casper.infradead.org>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39392 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911AbaIHNyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 09:54:21 -0400
Content-Disposition: inline
In-Reply-To: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/14 at 11:24am, Jiri Pirko wrote:
> This patchset can be divided into 3 main sections:
> - introduce switchdev api for implementing switch drivers
> - add hardware acceleration bits into openvswitch datapath, This uses
>   previously mentioned switchdev api
> - introduce rocker switch driver which implements switchdev api

Jiri, Scott,

Enclosed is the GOOG doc which outlines some details on my particular
interests [0]. It includes several diagrams which might help to
understand the overall arch. It is highly related to John's work as
well. Please let me know if something does not align with the model
you have in mind.

Summary:
The full virtual tunnel endpoint flow offload attempts to offload full
flows to the hardware and utilize the embedded switch on the host NIC
to empower the eSwitch with the required flexibility of the software
driven network. In this model, the guest (VM or LXC) attaches through a
SR-IOV VF which serves as the primary path. A slow path / software path
is provided via the CPU which can route packets back into the VF by
tagging packets with forwarding metadata and sending the frame back to
the NIC.

[0] https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit?usp=sharing
(Publicly accessible and open for comments)
