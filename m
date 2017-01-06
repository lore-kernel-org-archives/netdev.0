From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Synchronize access to mailbox
Date: Fri, 6 Jan 2017 03:08:25 +0000
Message-ID: <D457A6F6-246F-4FAF-82BE-E736DA4B3328@chelsio.com>
References: <1483595590-12932-1-git-send-email-hariprasad@chelsio.com>,<20170105.110532.154981132261843828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Casey Leedom <leedom@chelsio.com>,
        Nirranjan Kirubaharan <nirranjan@chelsio.com>,
        "Ganesh GR" <ganeshgr@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0135.outbound.protection.outlook.com ([104.47.41.135]:16097
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754330AbdAFDX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 22:23:57 -0500
In-Reply-To: <20170105.110532.154981132261843828.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> On 05-Jan-2017, at 9:35 PM, David Miller <davem@davemloft.net> wrote:
>=20
> From: Hariprasad Shenai <hariprasad@chelsio.com>
> Date: Thu,  5 Jan 2017 11:23:10 +0530
>=20
>> @@ -844,6 +848,10 @@ struct adapter {
>>    struct work_struct db_drop_task;
>>    bool tid_release_task_busy;
>>=20
>> +    /* lock for mailbox cmd list */
>> +    spinlock_t mbox_lock;
>> +    struct mbox_list mlist;
>> +
> ...
>> @@ -4707,6 +4707,9 @@ static int init_one(struct pci_dev *pdev, const st=
ruct pci_device_id *ent)
>>    spin_lock_init(&adapter->stats_lock);
>>    spin_lock_init(&adapter->tid_release_lock);
>>    spin_lock_init(&adapter->win0_lock);
>> +    spin_lock_init(&adapter->mbox_lock);
>> +
>> +    INIT_LIST_HEAD(&adapter->mbox_list.list);
>=20
> It is absolutely impossible that you even compiled this code.

My bad. Looks like I sent wrong patch. I will send V2 for the same.=
