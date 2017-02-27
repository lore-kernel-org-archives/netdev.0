From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH v3 20/20] checkpatch: warn for use of old PCI pool API
Date: Mon, 27 Feb 2017 13:26:21 +0100
Message-ID: <7ebf56b6-4e22-05ba-2534-61cd03a2c87c@collabora.com>
References: <20170226192425.13098-1-romain.perier@collabora.com>
 <20170226192425.13098-21-romain.perier@collabora.com>
 <20170227112233.GK26544@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>,
        Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
To: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170227112233.GK26544-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,


Le 27/02/2017 à 12:22, Peter Senna Tschudin a écrit :
> On Sun, Feb 26, 2017 at 08:24:25PM +0100, Romain Perier wrote:
>> pci_pool_*() functions should be replaced by the corresponding functions
>> in the DMA pool API. This adds support to check for use of these pci
>> functions and display a warning when it is the case.
>>
> I guess Joe Perches did sent some comments for this one, did you address
> them?

See the changelog of 00/20 (for v2). I have already integrated his
comments :)

>
> Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
>> Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
>> ---
>>  scripts/checkpatch.pl | 9 ++++++++-
>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>
>> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
>> index baa3c7b..f2c775c 100755
>> --- a/scripts/checkpatch.pl
>> +++ b/scripts/checkpatch.pl
>> @@ -6064,7 +6064,14 @@ sub process {
>>  			WARN("USE_DEVICE_INITCALL",
>>  			     "please use device_initcall() or more appropriate function instead of __initcall() (see include/linux/init.h)\n" . $herecurr);
>>  		}
>> -
>> +# check for old PCI api pci_pool_*(), use dma_pool_*() instead
>> +		if ($line =~ /\bpci_pool(?:_(?:create|destroy|alloc|zalloc|free)|)\b/) {
>> +			if (WARN("USE_DMA_POOL",
>> +				 "please use the dma pool api or more appropriate function instead of the old pci pool api\n" . $herecurr) &&
>> +			    $fix) {
>> +				while ($fixed[$fixlinenr] =~ s/\bpci_pool(_(?:create|destroy|alloc|zalloc|free)|)\b/dma_pool$1/) {}
>> +			}
>> +		}
>>  # check for various structs that are normally const (ops, kgdb, device_tree)
>>  		if ($line !~ /\bconst\b/ &&
>>  		    $line =~ /\bstruct\s+($const_structs)\b/) {
>> -- 
>> 2.9.3
>>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
