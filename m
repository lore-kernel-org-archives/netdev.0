From: "Robert Dobrowolski" <robert.dobrowolski@linux.intel.com>
Subject: Re: [PATCH v1] net: cdc_ncm: update datagram size after changing
     mtu
Date: Mon, 11 Apr 2016 05:00:36 -0700 (PDT)
Message-ID: <52026.10.237.143.103.1460376036.squirrel@linux.intel.com>
References: <1459942869-13587-1-git-send-email-robert.dobrowolski@linux.intel.com>
    <87h9fex0ql.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Robert Dobrowolski" <robert.dobrowolski@linux.intel.com>,
	linux-usb@vger.kernel.org, rafal.f.redzimski@intel.com,
	stable@vger.kernel.org, oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?iso-8859-1?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52226 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015AbcDKLNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 07:13:04 -0400
In-Reply-To: <87h9fex0ql.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Robert Dobrowolski <robert.dobrowolski@linux.intel.com> writes:
>
>> From: Rafal Redzimski <rafal.f.redzimski@intel.com>
>>
>> Current implementation updates the mtu size and notify cdc_ncm
>> device using USB_CDC_SET_MAX_DATAGRAM_SIZE request about datagram
>> size change instead of changing rx_urb_size.
>>
>> Whenever mtu is being changed, datagram size should also be
>> updated.
>
> Definitely!  Thanks for this.  But looking at the code I believe you
> need to fix the calculation of maxmtu too.  It is currently:
>
>   int maxmtu =3D ctx->max_datagram_size - cdc_ncm_eth_hlen(dev);
>
> And cdc_ncm_set_dgram_size() updates ctx->max_datagram_size with the =
new
> mtu, meaning that you can only reduce the mtu.  We should probably us=
e
> cdc_ncm_max_dgram_size() instead here.
>
> And cdc_ncm_set_dgram_size() takes the datagram size with header as
> input (ref the above maxmtu calucalution), so it probably needs to
> called as
>
>   cdc_ncm_set_dgram_size(dev, new_mtu + cdc_ncm_eth_hlen(dev));
>
> to get it right.  I think.  None of this is tested on an actual devic=
e
> yet...  Care to test if I'm right, and do a v2 if necessry?
>
>> Cc: <stable@vger.kernel.org>
>
> This should be dropped for net.  Ask David to queue it for stable
> instead.  I usually do that by using a subject prefix like
>
>  [PATCH net,stable v1] ...
>
>
>
>
> Bj=C3=B8rn
>

ok, thanks for feedback I will send v2 patch
