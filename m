From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [next-queue PATCH v2 2/5] net/sched: Fix accessing invalid
 dev_queue
Date: Mon, 2 Oct 2017 08:57:06 -0700
Message-ID: <bb111622-1a5c-2a8b-f526-c94f7b77d454@intel.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com>
 <20170930002657.15291-3-vinicius.gomes@intel.com>
 <CAM_iQpW7YtS2=rRw814=zWcJaUOGmkWQ+NHQKPwsBF4hMQSRVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        Ivan Briano <ivan.briano@intel.com>, boon.leong.ong@intel.com,
        richardcochran@gmail.com, Henrik Austad <henrik@austad.us>,
        levipearson@gmail.com, rodney.cummings@ni.com
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:8338 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751061AbdJBQEH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 12:04:07 -0400
In-Reply-To: <CAM_iQpW7YtS2=rRw814=zWcJaUOGmkWQ+NHQKPwsBF4hMQSRVg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09/30/2017 05:22 PM, Cong Wang wrote:
> On Fri, Sep 29, 2017 at 5:26 PM, Vinicius Costa Gomes
> <vinicius.gomes@intel.com> wrote:
>> From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>>
>> In qdisc_alloc() the dev_queue pointer was used without any checks being
>> performed. If qdisc_create() gets a null dev_queue pointer, it just
>> passes it along to qdisc_alloc(), leading to a crash. That happens if a
>> root qdisc implements select_queue() and returns a null dev_queue
>> pointer for an "invalid handle", for example.
> 
> Does it make sense to let mqprio_select_queue() always return
> non-NULL?
> 
> At least mq_select_queue() returns queue #0 as a fallback.

I had seen that, but my understanding was that for mqprio the inner qdiscs are
always related to one of the Tx netdev_queue per design. Returning any other
queue as a fallback seemed like going against that to me.

I'd rather keep this function as the patch is proposing, thus either returning
the correct netdev_queue for a given handle, or NULL as a way to flag that
something was 'wrong' with it. Returning queue #0 is misleading in that sense, imo.

What do you think?

Regards,
Jesus
