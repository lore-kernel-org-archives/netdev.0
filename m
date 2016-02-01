From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC net-next 2/9] net/switchdev: Introduce hardware offload
 support
Date: Mon, 01 Feb 2016 01:26:06 -0800
Message-ID: <56AF24AE.8030101@gmail.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me> <1454315685-32202-3-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.com>
To: Amir Vadai <amir@vadai.me>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34102 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbcBAJ0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 04:26:21 -0500
Received: by mail-pa0-f47.google.com with SMTP id uo6so80489542pac.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 01:26:21 -0800 (PST)
In-Reply-To: <1454315685-32202-3-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-01 12:34 AM, Amir Vadai wrote:
> Extend the switchdev API with new operations: switchdev_port_flow_add()
> and switchdev_port_flow_del().
> It allows the user to add/del a hardware offloaded flow classification
> and actions.
> For every new flow object a cookie is supplied. This cookie will be
> used later on to identify the flow when removed.
> 
> In order to make the API as flexible as possible, flow_dissector is
> being used to describe the flow classifier.
> 
> Every new flow object is consists of a flow_dissector+key+mask to
> describe the classifier and a switchdev_obj_port_flow_act to describe
> the actions and their attributes.
> 
> object is passed to the lower layer driver to be pushed into the
> hardware.
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>
> ---

+Scott

[...]

> +struct switchdev_obj_port_flow {
> +	struct switchdev_obj obj;
> +
> +	unsigned long cookie;
> +	struct flow_dissector *dissector; /* Dissector for mask and keys */
> +	void *mask; /* Flow keys mask */
> +	void *key;  /* Flow keys */

The heavy use of void* here and below seems questionable to me. If your
going to consume flow keys/mask define them.

> +	struct switchdev_obj_port_flow_act *actions;
> +};

[...]
