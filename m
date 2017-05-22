From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH 2/2] vhost/scsi: Delete error messages for failed memory
 allocations in five functions
Date: Mon, 22 May 2017 12:50:39 +0200
Message-ID: <557bdff4-6dc2-756d-0d59-9f688ef11f0a@users.sourceforge.net>
References: <bafa65e4-08fe-efdb-d836-7657e8a64749@users.sourceforge.net>
 <babc429d-6440-92aa-e1d0-eee2636a8d0f@users.sourceforge.net>
 <20170522094320.GE12205@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Wolfram Sang <wsa@the-dreams.de>
To: Stefan Hajnoczi <stefanha@gmail.com>, kvm@vger.kernel.org,
        netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        kernel-janitors@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20170522094320.GE12205@stefanha-x1.localdomain>
Content-Language: en-GB
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
> 
> Please include an actual explanation for this change instead of linking
> to slides.

Do you care for a bit of code size reduction by removal of questionable
error messages?


> Why are you trying to get rid of memory allocation failure messages?

Do you find information from a Linux allocation failure report sufficient
for any function implementations here?


>> +++ b/drivers/vhost/scsi.c
>> @@ -417,5 +417,4 @@ vhost_scsi_allocate_evt(struct vhost_scsi *vs,
>>  	if (!evt) {
>> -		vq_err(vq, "Failed to allocate vhost_scsi_evt\n");
> 
> #define vq_err(vq, fmt, ...) do {                                  \
>                 pr_debug(pr_fmt(fmt), ##__VA_ARGS__);       \
>                 if ((vq)->error_ctx)                               \
>                                 eventfd_signal((vq)->error_ctx, 1);\
>         } while (0)
> 
> You silently dropped the eventfd_signal() call.

Do you prefer to preserve this special error handling then?

Regards,
Markus
