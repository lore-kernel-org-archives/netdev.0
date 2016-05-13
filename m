From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 13 May 2016 23:01:11 +0200
Message-ID: <2606282.lG9qK7uBW0@wuerfel>
References: <20160510112905.5bffcad8@canb.auug.org.au> <20160510183934.GJ1256@tuxbot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	Andy Gross <andy.gross@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	Olof Johansson <olof@lixom.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20160510183934.GJ1256@tuxbot>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 10 May 2016 11:39:34 Bjorn Andersson wrote:
> On Mon 09 May 18:29 PDT 2016, Stephen Rothwell wrote:
> 
> > Hi all,
> > 
> > After merging the net-next tree, today's linux-next build (x86_64
> > allmodconfig) failed like this:
> > 
> > net/qrtr/smd.c:106:14: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
> >   .callback = qcom_smd_qrtr_callback,
> >               ^
> > net/qrtr/smd.c:106:14: note: (near initialization for 'qcom_smd_qrtr_driver.callback')
> > 
> > Caused by commit
> > 
> >   bdabad3e363d ("net: Add Qualcomm IPC router")
> > 
> > interacting with commit
> > 
> >   b853cb9628bf ("soc: qcom: smd: Make callback pass channel reference")
> > 
> > from the arm-soc tree.
> > 
> > I added the following merge fix patch (and it turned out I needed the
> > new stubs).
> > 
> 
> Sorry for not spotting this issue earlier, I missed Andy's second pull
> request towards arm-soc and thought the SMD changes missed this cycle.
> 
> 
> Your patch looks good, but I'm not sure how we should approach the merge
> window; Andy can't pick the patch because he doesn't have the qrtr code
> and David doesn't have the SMD patches coming through Andy.
> 
> FWIW, Reviewed-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> 
> 
> I assume we could have the QRTR go through Andy and arm-soc, with
> David's approval and this fix squashed in. But we're running rather late
> in this cycle, perhaps we should just back the QRTR patches out and I
> can respin and resend them after the merge window (for v4.8 instead)?

I'd suggest you do a merge of next-next with the qcom/soc-2 branch that
we have in arm-soc and resolve the conflict in the merge, then send
a pull request with the merge to davem.

Alternatively, in case Linus merges net-next before we get that fix
in, I could send Stephen's fix to Linus along with the pull requests.

	Arnd
