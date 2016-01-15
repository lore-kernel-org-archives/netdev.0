From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3] ovs: limit ovs recursions in ovs_execute_actions
 to not corrupt stack
Date: Fri, 15 Jan 2016 08:45:57 -0800
Message-ID: <1452876357.1223.178.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452868427-5655-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin Shelar <pshelar@ovn.org>,
	Simon Horman <simon.horman@netronome.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36784 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbcAOQqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 11:46:00 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so304454952pab.3
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 08:45:59 -0800 (PST)
In-Reply-To: <1452868427-5655-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-15 at 15:33 +0100, Hannes Frederic Sowa wrote:
> It was seen that defective configurations of openvswitch could overwrite
> the STACK_END_MAGIC and cause a hard crash of the kernel because of too
> many recursions within ovs.

...

> +
> +	preempt_disable();
> +	level = __this_cpu_inc_return(exec_actions_level);
> +	if (level > ovs_recursion_limit) {

if (unlikely(level > ovs_recursion_limit)) {
