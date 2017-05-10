From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH] wcn36xx: Close SMD channel on device removal
Date: Wed, 10 May 2017 10:52:55 -0700
Message-ID: <20170510175254.GS15143@minitux>
References: <20170509043637.28179-1-bjorn.andersson@linaro.org>
 <87h90u3672.fsf@kamboji.qca.qualcomm.com>
 <20170509230312.GR15143@minitux>
 <6e1cc217-924f-c536-6009-f6a377844d6f@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Eyal Ilsar <c_eilsar@qti.qualcomm.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org
To: Arend van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6e1cc217-924f-c536-6009-f6a377844d6f@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed 10 May 00:27 PDT 2017, Arend van Spriel wrote:

> On 5/10/2017 1:03 AM, Bjorn Andersson wrote:
> > On Mon 08 May 23:17 PDT 2017, Kalle Valo wrote:
> > 
> > > Bjorn Andersson <bjorn.andersson@linaro.org> writes:
> > > 
> > > > The SMD channel is not the primary WCNSS channel and must explicitly be
> > > > closed as the device is removed, or the channel will already by open on
> > > > a subsequent probe call in e.g. the case of reloading the kernel module.
> > > > 
> > > > This issue was introduced because I simplified the underlying SMD
> > > > implementation while the SMD adaptions of the driver sat on the mailing
> > > > list, but missed to update these patches. The patch does however only
> > > > apply back to the transition to rpmsg, hence the limited Fixes.
> > > > 
> > > > Fixes: 5052de8deff5 ("soc: qcom: smd: Transition client drivers from smd to rpmsg")
> > > > Reported-by: Eyal Ilsar <c_eilsar@qti.qualcomm.com>
> > > > Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> > > 
> > > As this is a regression I'll queue this to 4.12.
> > > 
> > 
> > Thanks.
> > 
> > > But if this is an older bug (didn't quite understand your description
> > > though) should there be a separate patch for stable releases?
> > > 
> > 
> > AFAICT this never worked, as it seems I did the rework in SMD while we
> > tried to figure out the dependency issues we had with moving to SMD. So
> > v4.9 through v4.11 has SMD support - with this bug.
> > 
> > How do I proceed, do you want me to write up a fix for stable@? Do I
> > send that out as an ordinary patch?
> 
> If the patch applies cleanly on branches linux-4.9.y through linux-4.11.y in
> the stable repository you can go for '--- Option 1 ---' as described in
> <linux-repo>/Documentation/stable_kernel_rules.txt.
> 

It does not, before v4.12 it's a completely different function to call
to close the channel.

But "Option 3" describes the situation, thanks for the reference. I'll
try to find the time to verify the patch on v4.11 and send it to
stable@.

Regards,
Bjorn
