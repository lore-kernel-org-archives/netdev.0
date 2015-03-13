From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [PATCH 2/3 RFC] ath10k: wmi: match wait_for_completion_timeout
 return type
Date: Fri, 13 Mar 2015 07:47:45 +0100
Message-ID: <CA+BoTQ=VYkOcKBjBuLsJcDjPNevTD2UFxVfB1uimRr=9uBO4Fw@mail.gmail.com>
References: <1426175362-8640-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	"ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426175362-8640-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 March 2015 at 16:49, Nicholas Mc Guire <hofrat@osadl.org> wrote:
> Return type of wait_for_completion_timeout is unsigned long not int.
> An appropriately named unsigned long is added and the assignments fix=
ed up.
> Rather than returning 0 (timeout) or a more or less random remaining =
time
> (completion success) this return 0 or 1 which also resolves the type =
of the
> functions being int.
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> ---
>
> Checking the call-sites of ath10k_wmi_wait_for_unified_ready and
> ath10k_wmi_wait_for_service_ready the positive return value (remainin=
g
> time in jiffies) is never passed up the call-chain nor used so it is
> cleaner to treat this like a boolean success/fail only (actually the =
two
> functions should probably be of type bool - but that does not seem to=
 be
> common practice in the ath10k code base)

It'd make sense to have these functions return 0 or -ETIMEDOUT. In
that case both call sites would need to be adjusted to treat "< 0" or
"!x" as an error (instead of the current "<=3D 0") condition and not se=
t
-ETIMEDOUT themselves.


Micha=C5=82
