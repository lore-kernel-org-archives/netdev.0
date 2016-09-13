From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [RFC 08/11] Add support for data path
Date: Tue, 13 Sep 2016 17:32:13 +0300
Message-ID: <40a9df9e-a0aa-9020-c523-6042baf729d1@grimberg.me>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-9-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696465-27986-9-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> +	pbe = (struct regpair *)pbl_table->va;
> +	num_pbes = 0;
> +
> +	for (i = 0; i < mr->npages &&
> +	     (total_num_pbes != mr->info.pbl_info.num_pbes); i++) {
> +		u64 buf_addr = mr->pages[i];
> +
> +		pbe->lo = cpu_to_le32((u32)buf_addr);
> +		pbe->hi = cpu_to_le32((u32)upper_32_bits(buf_addr));

Thats a shame... you could have easily set the buf_addr correctly
in qedr_set_page...

I think you could have also set the pbe directly from set_page if you
have access to pbl_table from your mr context
(and if I understand correctly I think you do, mr->info.pbl_table)...
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
