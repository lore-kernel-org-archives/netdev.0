From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 18 May 2016 11:45:06 -0700
Message-ID: <CA+55aFxThzV3myrHv0XZbubEdGhg5=rGE6dK=+L1ddc9sufdCQ@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
	<CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
	<CANUX_P3n0ZkTw0fY8wD3biu2mLzrwyX7n=bo1otw9m0bpfS07Q@mail.gmail.com>
	<1463568714.13625.18.camel@intel.com>
	<CAAA5faF=SxqCt0yDTbPyUoc3gFD--_co+fRj2Jfuy=whEQvcBQ@mail.gmail.com>
	<1463575273.13625.23.camel@intel.com>
	<CAAA5faHtbt8oyKEQOJ+NMBKR24b7Nvm6uJ2qZid1sWY58e7f+A@mail.gmail.com>
	<1463581411.29999.1.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "reinoudkoornstra@gmail.com" <reinoudkoornstra@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"egrumbach@gmail.com" <egrumbach@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463581411.29999.1.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 7:23 AM, Coelho, Luciano
<luciano.coelho@intel.com> wrote:
>
> I can confirm that 4.6 contains the same bug.  And reverting the patch
> I mentioned does solve the problem...
>
> The same patch works fine in our internal tree.  I'll have to figure
> out together with Emmanuel what the problem actually is.

Hmm.

>From what I can tell, there's a merge bug in commit 909b27f70643,
where David seems to have lost some of the changes to
iwl_mvm_set_tx_cmd().

The reason seems to be a conflict with d8fe484470dd, where David
missed the fact that "info->driver_data[0]" had become
"skb_info->driver_data[0]", and then he removed the skb_info because
it was unused.

I do not know if that's the reason for the problem I see. But I will test.

David, do you happen to recall that merge conflict? I think you must
have removed that "skb_info" variable declaration and initialization
manually (due to the "unused variable" warning, which in turn was due
to the incorrect merge of the actual conflict), because I think git
would have merged that line into the result.

                  Linus
