From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 5 Sep 2013 12:25:00 -0700
Message-ID: <CAEP_g=8Phux4eMz_b45XvEddkJKkTkkGzg+jvVKLBx4Ztiu=5w@mail.gmail.com>
References: <1378402887-17331-1-git-send-email-jesse@nicira.com>
 <20130905.141751.945639989861997124.davem@davemloft.net> <CAEP_g=8gcCtkv=no=HkVmS+NDWPM-Uu-SVyR+vb-YQ=7TWJsXA@mail.gmail.com>
 <20130905.144044.1053960608071929025.davem@davemloft.net> <CAMuHMdVgd499_oAU0oodE8ie+h+Oc6M-dRcyC4tT6QDB=01GSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Andy Zhou <azhou@nicira.com>, fengguan.wu@intel.com
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:40772 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752843Ab3IETZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:25:23 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so2060291lbh.19
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 12:25:20 -0700 (PDT)
In-Reply-To: <CAMuHMdVgd499_oAU0oodE8ie+h+Oc6M-dRcyC4tT6QDB=01GSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 5, 2013 at 12:20 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> Why don't you abort the loop if a difference is found?
> Or is this a security-related struct where you want to protect against
> timing attacks?

It's more expensive to test for a difference on every iteration in the
common case where the comparison succeeds.

> Furthermore, as you compare the raw bytes, I hope you always
> initialize all gaps in the struct to zero.
> E.g. there's a 2-byte gap immediately after "ip", as the next member
> is 32-bit (except op m68k, where the 32-bit member will be 2-byte aligned).

It's initialized to zero.
