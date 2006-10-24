From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Tue, 24 Oct 2006 18:03:18 -0400
Message-ID: <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:11765 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1422710AbWJXWDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 18:03:20 -0400
Received: by ug-out-1314.google.com with SMTP id 32so344514ugm
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 15:03:18 -0700 (PDT)
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Simon Barber <simon@devicescape.com> wrote:
> The Client MLME code in the kernel was only ever written to be used for
> quick testing. It does not have good roaming performance, and was never
> intended to be a complete client. The right place for the Client MLME is
> in userspace, where it can be closely coupled with the supplicant, and
> better scanning and roaming decisions can be made. If the Client MLME is
> removed from the kernel, then a userspace part is always required in
> order for 802.11 to be used at all. (It's already required in order to
> use any of the recent security modes, or have automatic network
> selection, or decent roaming). In this case the regulatory constraints
> can be set in a privileged userspace deamon.

We also have to take into consideration FullMAC devices where we don't
need an MLME implemented in kernel/userspace and how regulatory domain
control will dictate their behaviour. My approach here was to support
a map between stack regulatory domain values and device regulatory
domain values. This is currently provided by ieee80211_regdomains. We
can add to ieee80211_conf a ieee80211_regulatory_map and if defined
d80211 will simply call the the stack's set regdomain which the device
implements and sets the regdomain internally to whatever the device
should have.

Mind you I realize most new devices are taking the SoftMAC design
approach and while these vary ultimately I do agree with your point.

All that said though:

1. Anyone working on completing FullMAC support on d80211?
2. Who's working on a userspace MLME replacement for d80211 and where
are we with that?
3. Who's doing the endianness/smp testing of d80211 and how far are we
with that?

Lastly, as I have said in previous e-mails -- I agree with a userspace
daemon but where is it and how long before its ready.. also it may be
difficult to introduce as a requirement for distributions and for this
reason I am suggesting going with in-kernel regulatory domain control
and now perhaps in-kernel MLME for a first stable push of d80211,
specially since only... 3 in-kernel drivers currently use d80211!

  Luis
