From: Christos Gkekas <chris.gekas@gmail.com>
Subject: Re: [PATCH] ath10k: spectral: Simplify error checking
Date: Sat, 14 Oct 2017 09:12:57 +0100
Message-ID: <20171014081257.GA3961@inspiron>
References: <1507491026-28690-1-git-send-email-chris.gekas@gmail.com>
 <87fuannse6.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fuannse6.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/10/17 12:28:50 +0000, Kalle Valo wrote:
> Christos Gkekas <chris.gekas@gmail.com> writes:
> 
> > Variable val is unsigned so checking whether it is less than zero is
> > redundant.
> >
> > Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
> > ---
> >  drivers/net/wireless/ath/ath10k/spectral.c | 5 +----
> >  1 file changed, 1 insertion(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/wireless/ath/ath10k/spectral.c b/drivers/net/wireless/ath/ath10k/spectral.c
> > index dd9cc09..1867937 100644
> > --- a/drivers/net/wireless/ath/ath10k/spectral.c
> > +++ b/drivers/net/wireless/ath/ath10k/spectral.c
> > @@ -403,10 +403,7 @@ static ssize_t write_file_spectral_count(struct file *file,
> >  		return -EFAULT;
> >  
> >  	buf[len] = '\0';
> > -	if (kstrtoul(buf, 0, &val))
> > -		return -EINVAL;
> > -
> > -	if (val < 0 || val > 255)
> > +	if (kstrtoul(buf, 0, &val) || val > 255)
> >  		return -EINVAL;
> 
> Removing the check for negative is correct but I don't think you are
> simplifying anything, on the contrary it's harder to read. Please keep
> the two if statements separate.
> 
> -- 
> Kalle Valo

You are right, will make the change and send a new patch.
Thanks for your time.

Christos Gkekas
