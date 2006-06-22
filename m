From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Thu, 22 Jun 2006 08:39:10 -0700
Message-ID: <4807377b0606220839i5de14797ocb9e404fd21540e3@mail.gmail.com>
References: <20060622051815.25497.89192.stgit@gitlost.site>
	 <20060622052029.25497.67575.stgit@gitlost.site>
	 <449A2B20.2020006@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:6572 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751814AbWFVPjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 11:39:10 -0400
Received: by ug-out-1314.google.com with SMTP id a2so551843ugf
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 08:39:10 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <449A2B20.2020006@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/21/06, Ben Greear <greearb@candelatech.com> wrote:
> Kok, Auke wrote:
> > CRC stripping is breaking SMBUS-connected BMC's. We disable this
> > feature to make it work. This fixes related bugs regarding SOL.
>
> Shouldn't you also have to subtract 4 bytes when setting the skb len
> in the receive logic?  Perhaps when setting the rx-bytes counter as well?

we thought about this, but most drivers don't strip the CRC, and we
couldn't find any tests including bridging that cared if the CRC was
there in the indicated packet.

If you can find me a failing case I'll fix it.  It was much simpler to
leave it out, especially when we add back in the multiple descriptor
receive code in the future (think about the case when subtracting the
CRC makes the last descriptor disappear)

Once again, let me know if you have info I don't :-)

Thanks for the review,
  Jesse
