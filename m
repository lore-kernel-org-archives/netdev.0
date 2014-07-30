From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: Manual loading of mlx4_en
Date: Tue, 29 Jul 2014 19:14:00 -0700
Message-ID: <20140730021400.GA25996@f1.synalogic.ca>
References: <1406627612.4498.16.camel@chaos.site>
 <53D7748A.6040800@mellanox.com>
 <20140729123405.6802fbc4@endymion.delvare>
 <53D77B26.3070905@mellanox.com>
 <1406635578.4498.18.camel@chaos.site>
 <53D7A4C0.8090004@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean Delvare <jdelvare@suse.de>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:43014 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724AbaG3COE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 22:14:04 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so636509pab.12
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 19:14:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53D7A4C0.8090004@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/07/29 16:42, Amir Vadai wrote:
> On 7/29/2014 3:06 PM, Jean Delvare wrote:
> > Le Tuesday 29 July 2014 =E0 13:44 +0300, Amir Vadai a =E9crit :
> >> On 7/29/2014 1:34 PM, Jean Delvare wrote:
> >>> Many thanks for the fast and detailed answer! I'll go backport th=
is
> >>> commit to kernel 3.12 (and 3.0, hopefully it doesn't have too man=
y
> >>> dependencies?)
> >>
> >> I don't think there is any dependency for that commit. If you're
> >> backporting it, also take a small fix to it:
> >> f24f790 net/mlx4_core: Load the Eth driver first
> >=20
> > Thanks for the hint. I suppose I should pick 7855bff4 "net/mlx4_cor=
e:
> > Load the IB driver when the device supports IBoE" as well?
> >=20
> Right - missed it.

Thanks for the pointers.
Looking at f24f790f, I'm wondering if request_module(EN_DRV_NAME) ought
to be used instead of _nowait to guarantee the desired effect. Suppose
for example that the process is migrated to a different cpu between the
two request_module calls, the second one could complete before the firs=
t
one no?
