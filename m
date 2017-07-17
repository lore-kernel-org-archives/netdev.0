From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: stmmac: issue while performing iperf data flood
Date: Mon, 17 Jul 2017 16:22:23 +0100
Message-ID: <19ed3c45-1a23-8426-4dad-a19790759b94@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay4.synopsys.com ([198.182.47.9]:35397 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdGQPW1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:22:27 -0400
Received: from mailhost.synopsys.com (mailhost2.synopsys.com [10.13.184.66])
        by smtprelay.synopsys.com (Postfix) with ESMTP id 8A82924E1F1B
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 08:22:26 -0700 (PDT)
Received: from mailhost.synopsys.com (localhost [127.0.0.1])
        by mailhost.synopsys.com (Postfix) with ESMTP id 7BA9EF59
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 08:22:26 -0700 (PDT)
Received: from US01WXQAHTC1.internal.synopsys.com (us01wxqahtc1.internal.synopsys.com [10.12.238.230])
        by mailhost.synopsys.com (Postfix) with ESMTP id 71AC8F56
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 08:22:26 -0700 (PDT)
Content-Language: pt-PT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello to all,

I am executing some tests in stmmac regarding its multiple tx queue capability.

My setup is routing through queue 0 generic traffic and through queue 2 higher
priority traffic. It works fine, but when I execute a data flood using iperf in
the TX side, the interface goes down, instead of giving the higher traffic the
free pass and manage the generic traffic as good as possible. The command I am
executing is:

    iperf -c <other_end_ip> -u -b 1000M -t 60

The interface begins to drop packets (assuming this from return value of
dev_queue_xmit -> =1) and so the queues start to have timeouts.

If I use the same queue index, no problem happens, being perfectly capable of
sending both traffic types in a single queue. When using two queues, it does not
work, I think they might be entering in some kind of race.

Any ideas about this? Has anyone encountered this problem or similar?

Thak you so much.

Best regards,

Joao
