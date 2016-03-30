From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] i40e/i40evf: Limit TSO to 7 descriptors for payload
 instead of 8 per packet
Date: Wed, 30 Mar 2016 10:35:55 -0700
Message-ID: <CAKgT0Ufb-_X-DD2jYkVJQwLZ-JBfWD2Biuhi6YaxWBeNy9K2fQ@mail.gmail.com>
References: <20160330064213.12927.46852.stgit@localhost.localdomain>
	<20160330170011.GB27540@oracle.com>
	<CAKgT0UdTgaeamyLetGPK0mqMNS-80BTc8t-WdSGJuuLDfz4JOg@mail.gmail.com>
	<20160330172001.GD27540@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38743 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236AbcC3Rf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 13:35:56 -0400
Received: by mail-ig0-f179.google.com with SMTP id ui10so38834275igc.1
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 10:35:56 -0700 (PDT)
In-Reply-To: <20160330172001.GD27540@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 10:20 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/30/16 10:12), Alexander Duyck wrote:
>> Yeah.  The patch was sort of a knee-jerk reaction to being told that
>> the patch referenced caused a regression.  From what I can tell that
>> is not the case as I am also seeing the Tx hangs when I run the test
>> with the frames being linearized.
>
> I'm not sure how important of a subtlety this is, but the actual
> console log after the patch is the following:
>
>  i40e 0000:82:00.0: TX driver issue detected, PF reset issued
>  i40e 0000:82:00.0 eth2: adding 68:05:ca:30:dd:18 vid=0
>  i40e 0000:82:00.0: TX driver issue detected, PF reset issued
>  i40e 0000:82:00.0 eth2: adding 68:05:ca:30:dd:18 vid=0
>  i40e 0000:82:00.0: TX driver issue detected, PF reset issued
>
> Comparing with what I'd pasted in the sourceforge thread earlier,
> I see that it does not say "Hung Tx queue etc."  any more, though
> it still resets.
>
> Not sure if that changed info is significant?

It might be.  Right now I am chasing down the Tx driver issue as that
I what I am reproducing in my environment as well.

>From what I can tell by enabling msglvl tx_err it is reporting MDD
event 0x2.  Unfortunately the documentation doesn't say what that is
so I am checking a few different possibilities.

- Alex
