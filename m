From: Colin Ian King <colin.king@canonical.com>
Subject: Re: mlxsw: spectrum: Introduce ACL core with simple TCAM
 implementation
Date: Tue, 7 Feb 2017 14:13:34 +0000
Message-ID: <91866877-9d0a-61fd-8bab-4e5a2f5294e3@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Ido Schimmel <idosch@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48190 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754265AbdBGOPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 09:15:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

mlxsw_sp_acl_tcam_chunk_create has an issue picked up by static analysis:

 816        struct mlxsw_sp_acl_tcam_chunk *chunk;
 817        int err;
 818
    CID 1400029 (#1 of 1): Operands don't affect result
(CONSTANT_EXPRESSION_RESULT)result_independent_of_operands: priority ==
18446744073709551615UL is always false regardless of the values of its
operands. This occurs as the logical operand of "if".

 819        if (priority == MLXSW_SP_ACL_TCAM_CATCHALL_PRIO)
 820                return ERR_PTR(-EINVAL);
 821

priority is an unsigned int, where as MLXSW_SP_ACL_TCAM_CATCHALL_PRIO is
(-1UL), so the unsigned comparison to a signed long (-1UL) will never be
true. So I think this needs some reworking, especially as
MLXSW_SP_ACL_TCAM_CATCHALL_PRIO priority is being used as an unsigned
long priority in some places, and priority is an unsigned int in other
places of the code.

Colin
