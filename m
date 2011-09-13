From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/2] qlcnic: Change CDRP function
Date: Tue, 13 Sep 2011 13:56:24 -0700
Message-ID: <1315947384.25776.30.camel@Joe-Laptop>
References: <1315937179-22383-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1315937179-22383-2-git-send-email-anirban.chakraborty@qlogic.com>
	 <1315938171.25776.11.camel@Joe-Laptop>
	 <33055D09-742C-4751-9A4B-1AF11ED34E31@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54533 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932556Ab1IMU4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 16:56:24 -0400
In-Reply-To: <33055D09-742C-4751-9A4B-1AF11ED34E31@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

     On Tue, 2011-09-13 at 13:28 -0700, Anirban Chakraborty wrote:
> On Sep 13, 2011, at 11:22 AM, Joe Perches wrote:
> > On Tue, 2011-09-13 at 11:06 -0700, Anirban Chakraborty wrote:
> >> Argument list to CDRP function has become unmanageably long. Fix it by properly
> >> declaring a struct that encompasses all the input and output parameters.
> > I don't think this is better.
> > I think you've overloaded the issue_cmd function and should
> > use separate issue_cmd_<type> functions instead.
> I did not overload issue_cmd(), instead I changed the function signature. 
> -u32
> -qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
> -       u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd,
> -               u32 *rd_args[3])
> +void
> +qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
> Instead of having a long list of arguments, I put them into a struct and passed it around.

Yes, I saw that.

I think that if restructuring is done, perhaps there are
better alternatives to bundling all the arguments into a
single struct.

I think it might be more sensible to have multiple
issue_cmd_<cmd>(adapter, [appropriate_args]) functions
instead so that the arguments and returns are appropriate
for the cmd performed.

or maybe use

issue_cmd(adapter, cmd, struct)

so you make cmd explicit and it's a bit easier to read
if you really must use some struct where cmd doesn't
use all the elements of struct.
