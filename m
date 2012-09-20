From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH 5/6] xfrm_user: ensure user supplied esn replay window is valid
Date: Thu, 20 Sep 2012 09:13:19 +0200
Message-ID: <CA+rthh8r3UrBKCQ9kr4yAVpEkH3tpcCYXKt27yY64Snoi=bmBg@mail.gmail.com>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
	<1348090423-32665-6-git-send-email-minipli@googlemail.com>
	<1348094309.2636.80.camel@bwh-desktop.uk.solarflarecom.com>
	<CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Martin Willi <martin@revosec.ch>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+rthh8Q464Jw5okH5aXds0QZztay9dpcyniahtWFxev8tpN9w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 20, 2012 at 8:12 AM, Mathias Krause <minipli@googlemail.com> wrote:
> What still might happen is the overflow in xfrm_replay_state_esn_len()
> resulting in a to small bitmap allocation for the requested replay
> size. But that gets catched in xfrm_init_replay(). Little late, but
> hey.

Sorry, I mixed that up. The replay_window check in xfrm_init_replay()
has only little to do with the bmp_len overflow. But changing the
return type of xfrm_replay_state_esn_len() to size_t and by doing so,
making the all the size compares operating on positive values, we'll
at least allocate enough memory to not run into memory corruptions.
Though, the replay window will be much smaller, than requested -- due
to the overflow. But userland should expect this. A check for some
upper limit in verify_replay() could catch this early.

Mathias
