From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next 00/14] rocker: add support for multiple worlds
Date: Mon, 05 Oct 2015 08:41:38 -0700
Message-ID: <56129A32.1010201@gmail.com>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33491 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbbJEPlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 11:41:53 -0400
Received: by pacex6 with SMTP id ex6so180467974pac.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 08:41:52 -0700 (PDT)
In-Reply-To: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-04 02:25 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset allows new rocker worlds to be easily added in future (like eBPF
> based one I have been working on). The main part of the patchset is the OF-DPA
> carve-out. It resuts in OF-DPA specific file. Clean cut.
> The user is able to change rocker port world/mode using rtnl.
> 

Hi Jiri,

I'm not sure I understand the motivation here. Are you thinking the
"real" drivers will start to load worlds or what I've been calling
profiles on the devices I have here. If this is the case using
opaque strings without any other infrastructure around it to expose
what the profile is doing is not sufficient in my opinion. What I
would rather have is for drivers to expose the actual configuration
parameters they are using, preferable these would be both readable
and writable so we don't end up with what the firmware/device driver
writers think is best. I think we can get there by exposing a model
of the device and configuring "tables". I'll post my latest patch
set today to give you a better idea what I'm thinking here. Without
this I guess you will end up with drivers creating many profiles and
in no consistent way so you end up with here is my "vxlan" profile,
here is my "geneve" profile, here is my "magic-foo" profile, etc. I
wanted to avoid this.

But if this is only meant to be a rocker thing then why expose it on
the driver side vs just compiling it on the qemu side? If its just
for convenience and only meant for the emulated device we should be
clear in the documentation and patch set.

Final, comment can we abstract the interfaces better? An L2 and L3
table could be mapped generically onto a table pipeline model if the
driver gave some small hints like this is my l2 table and this is my l3
table. Then you don't need all the world specific callbacks and the
OF-DPA model just looks like an instance of a pipeline with some
specific hints where to put l2/l3 rules.

Like I said I'll send some patches, they will be a bit rough and
against fm10k driver. I'll just send out what I have end of day here.

.John
