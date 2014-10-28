From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Tue, 28 Oct 2014 13:57:13 -0700
Message-ID: <CAADnVQ+Z6-7sdWAEvHkKR==Nds6hqBfbfPmtUDiZXOTE9DRnGw@mail.gmail.com>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
	<20141028.144344.398016097830457432.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:33112 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbaJ1U5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 16:57:14 -0400
Received: by mail-qc0-f178.google.com with SMTP id b13so1443384qcw.37
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 13:57:13 -0700 (PDT)
In-Reply-To: <20141028.144344.398016097830457432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2014 at 11:43 AM, David Miller <davem@davemloft.net> wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 22 Oct 2014 17:29:06 +0200
>
>> The internal and netdev vport remain part of openvswitch.ko. Encap
>> vports including vxlan, gre, and geneve can be built as separate
>> modules and are loaded on demand. Modules can be unloaded after use.
>> Datapath ports keep a reference to the vport module during their
>> lifetime.
>>
>> Allows to remove the error prone maintenance of the global list
>> vport_ops_list.
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>
> Applied, thanks a lot Thomas.

Thomas,

it fails the build when lockdep is on:
ERROR: "lockdep_ovsl_is_held" [net/openvswitch/vport-gre.ko] undefined!
